//
//  CityTableViewCell.swift
//  weather
//
//  Created by Dmitriy Paranichev on 15.10.2022.
//

import UIKit

struct CityDataWeather {
    let city: String?
    let country: String?
    let lon: Double?
    let lat: Double?
    let state: String?
}

class CityTableViewCell: UITableViewCell {
    
    //MARK: - IBOutlets
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var countryLabel: UILabel!
    @IBOutlet weak var stateLabel: UILabel!
    
    //MARK: - funcs
    func configure(with data: CityDataWeather){
        guard let city = data.city,
              let country = data.country,
              let state = data.state else { return }
        
        self.cityLabel.text = city
        self.countryLabel.text = country
        self.stateLabel.text = state
    }
}
