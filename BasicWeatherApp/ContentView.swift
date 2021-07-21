//
//  ContentView.swift
//  testapp
//
//  Created by Sprocket Riggs on 7/19/21.
//

import SwiftUI
import Foundation

struct ContentView: View {
    @State private var tempToDisplay: Int?
    
    
    var body: some View {
        ZStack{
            LinearGradient(gradient: Gradient(colors: [.blue, Color("lightBlue")]),
                           startPoint: .topLeading,
                           endPoint: .bottomTrailing)
                .edgesIgnoringSafeArea(/*@START_MENU_TOKEN@*/.all/*@END_MENU_TOKEN@*/)
            VStack{
                if let tempToDisplay = tempToDisplay{
                    WeatherView(location: "Seattle, WA", iconName: "cloud.sun.fill", temperature: tempToDisplay)
                } else {
                    //TODO: make an error screen
                    Text("Error")
                }
                
                
                Spacer()
                
                Button {
                    print("tapped")
                    getTemp(completionHandler: {temp -> Void in
                        if let temperature = temp{
                            tempToDisplay = Int(temperature)
                        }
                    })
                } label: {
                    Text("Refresh")
                        .font(.system(size: 25))
                        .foregroundColor(.black)
                        .frame(width: 100, height: 40)
                        .background(Color(.white))
                        .cornerRadius(10)
                       
                        
                }
                Spacer()
                
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

struct WeatherView: View {
    var location: String
    var iconName: String
    var temperature: Int
    
    var body: some View {
        Text(location)
            .font(.system(size: 32, weight: .medium, design: .default))
            .foregroundColor(.white)
            .padding()
        
        VStack(spacing: 10){
            Image(systemName: iconName)
                .renderingMode(.original)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 180, height: 180)
            
            Text("\(temperature)°F")
                .font(.system(size: 70, weight: .light))
                .foregroundColor(.white)
        }
    }
}

//TODO: Refactor/move below code to a diff file

struct Weather: Codable {
    var temp: Double?
}

struct WeatherMain: Codable {
    let main: Weather
}

func decodeJSONData(JSONData: Data) -> Double{
    do{
        let weatherData = try? JSONDecoder().decode(WeatherMain.self, from:
                                                    JSONData)
        if let weatherData = weatherData {
            let weather = weatherData.main
            return(weather.temp!)
        }
    }
    // Fix
    return 0.0
}

//TODO: Try to improve usage of completion handlers and update to new swift syntax if needed
func pullJSONData(url: URL?, completionHandler: @escaping (Double?) -> Void) {
    print("pullJSONData successfully called")
    var finalData: Double?
    
    URLSession.shared.dataTask(with: url!) {data, response, error in
        if let error = error {
            print("An Error Occured! (\(error.localizedDescription))")
        }
        
        guard let response = response as? HTTPURLResponse, response.statusCode == 200
        else{
            print("Error: HTTP Response Code Error")
            return
        }
        
        guard let data = data else{
            print("Data pulled is nil!")
            return
        }
        
        finalData = decodeJSONData(JSONData: data)
        
        if let finalData = finalData {
            completionHandler(finalData)
        }
    }.resume()
    
}


func getTemp(completionHandler: @escaping (Double?) -> Void){
    let apiKey = "b7b1411c5d9c39bddca714640fbf6899"
    let city: String = "Seattle"
    let url = URL(string:
        "https://api.openweathermap.org/data/2.5/weather?q=\(city)&appid=\(apiKey)&units=imperial")
    var temp: Double?
    pullJSONData(url: url, completionHandler: {temperature -> Void in
        if let temperature = temperature{
            temp = temperature
            completionHandler(temp)
        }
    })
    
}

