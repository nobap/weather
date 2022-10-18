//
//  CityTableViewCell.swift
//  weather
//
//  Created by Dmitriy Paranichev on 15.10.2022.
//

import UIKit

class CityTableViewCell: UITableViewCell {
    
    //MARK: - let/var
    private var name: String?
    
    //MARK: - IBOutlets
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var countryLabel: UILabel!
    @IBOutlet weak var stateLabel: UILabel!
    
    //MARK: - funcs
    func configure(with data: CityLocationWeather){
        if let localizedName = data.local_names?[Locale.current.identifier] {
            self.name = localizedName
        } else {
            self.name = data.name
        }
        
        self.cityLabel.text = self.name
        self.countryLabel.text = data.country
        
        if let state = data.state {
            self.stateLabel.text = state
        }
    }
}
