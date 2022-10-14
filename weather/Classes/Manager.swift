//
//  Manager.swift
//  weather
//
//  Created by Dmitriy Paranichev on 13.10.2022.
//

import Foundation

class Manager {

    //MARK: - let/var
    static let shared = Manager()

    private let weatherURL = "https://api.openweathermap.org/data/2.5"
    private let keyAPI = "ed615047034b31320d3eb95c021d4664"
    private let lat = "60.9339411"
    private let lon = "76.5814274"

    //MARK: - inits
    private init() {}
    
    //MARK: - funcs
    func sendReqestForecast(completion: @escaping (ForecastWeather)->()) {
        guard let request = self.createURL(call: "forecast") else { return }
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            if error == nil, let data {
                do {
                    let json = try JSONDecoder().decode(ForecastWeather.self, from: data)
                    UserDefaults.standard.set(data, forKey: "dataForecastWeather")
                    completion(json)
                } catch let error {
                    print(error)
                }
            }
        }.resume()
    }
    
    func sendRequestCurrentWeather(completion: @escaping (CurrentWeather)->()) {
        guard let request = self.createURL(call: "weather") else { return }
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            if error == nil, let data {
                do {
                    let json = try JSONDecoder().decode(CurrentWeather.self, from: data)
                    UserDefaults.standard.set(data, forKey: "dataCurrentWeather")
                    completion(json)
                } catch let error {
                    print(error)
                }
            }
        }.resume()
    }
    
    func createURL(call: String) -> URLRequest? {
        let urlString = "\(self.weatherURL)/\(call)?lat=\(self.lat)&lon=\(self.lon)&units=metric&lang=en&appid=\(self.keyAPI)"
        guard let url = URL(string: urlString) else { return nil }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        return request
    }
}
