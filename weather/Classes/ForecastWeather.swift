//
//  CurrentWeather.swift
//  weather
//
//  Created by Dmitriy Paranichev on 13.10.2022.
//

import Foundation

struct ForecastWeather: Decodable {
    let cod: String
    let message: Int
    let cnt: Int
    let list: [List?]
    let city: City?
}

struct List: Decodable {
    let dt: Date?
    let main: MainList
    let weather: [WeatherList]
    let clouds: CloudsList
    let wind: WindList
    let visibility: Int?
    let pop: Double?
    let sys: SysList
    let dt_txt: String?
}

struct WeatherList: Decodable {
    let id: Int
    let main: String
    let description: String
    let icon: String?
}

struct MainList: Decodable {
    let temp: Double
    let feels_like: Double?
    let temp_min: Double?
    let temp_max: Double?
    let pressure: Int
    let sea_level: Int?
    let grnd_level: Int?
    let humidity: Int
    let temp_kf: Double?
}

struct CloudsList: Decodable {
    let all: Int?
}

struct WindList: Decodable {
    let speed: Double
    let deg: Int?
    let gust: Double?
}

struct SysList: Decodable {
    let pod: String?
}

struct City: Decodable {
    let id: Int
    let name: String
    let coord: CoordCity
    let country: String
    let population: Int
    let timezone: Int
    let sunrise: UInt64
    let sunset: UInt64
}

struct CoordCity: Decodable {
    let lon: Double
    let lat: Double
}
