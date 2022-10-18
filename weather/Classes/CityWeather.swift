//
//  CityWeather.swift
//  weather
//
//  Created by Dmitriy Paranichev on 15.10.2022.
//

import Foundation

struct CityLocationWeather: Decodable {
    let name: String
    let local_names: [String: String]?
    let lon: Double
    let lat: Double
    let country: String
    let state: String?
}
