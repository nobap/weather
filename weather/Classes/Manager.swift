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

    private let weatherURL = "https://api.openweathermap.org/"
    private let keyAPI = "ed615047034b31320d3eb95c021d4664"
    public var lat: Double = 51.5073219
    public var lon: Double = -0.1276474
    public var city: String?
    public var country: String?

    //MARK: - inits
    private init() {}
    
    //MARK: - funcs
    func sendReqestCityLocation(city: String, completion: @escaping ([CityLocationWeather])->()) {
        let urlString = "\(self.weatherURL)/geo/1.0/direct?q=\(city)&limit=10&appid=\(self.keyAPI)"
        guard let url = URL(string: urlString) else { return }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            if error == nil, let data {
                do {
                    let json = try JSONDecoder().decode([CityLocationWeather].self, from: data)
                    completion(json)
                } catch let error {
                    print(error)
                }
            }
        }.resume()
    }
    
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

                    self.city = json.name
                    self.country = json.sys.country

                    UserDefaults.standard.set(data, forKey: "dataCurrentWeather")
                    completion(json)
                } catch let error {
                    print(error)
                }
            }
        }.resume()
    }
    
    func createURL(call: String) -> URLRequest? {
        let urlString = "\(self.weatherURL)data/2.5/\(call)?lat=\(self.lat)&lon=\(self.lon)&units=metric&lang=en&appid=\(self.keyAPI)"
        guard let url = URL(string: urlString) else { return nil }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        return request
    }
}
