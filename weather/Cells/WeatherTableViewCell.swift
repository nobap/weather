//
//  WeatherTableViewCell.swift
//  weather
//
//  Created by Dmitriy Paranichev on 13.10.2022.
//

import UIKit

struct SimpleDataWeather {
    let date: Date?
    let icon: String?
    let temp: Double?
}

class WeatherTableViewCell: UITableViewCell {
    
    //MARK: - IBOutlets
    @IBOutlet weak var date: UILabel!
    @IBOutlet weak var icon: UIImageView!
    @IBOutlet weak var temperature: UILabel!
    
    //MARK: - let/var
    let locale = "en_US_POSIX"
    let dateFormat = "EE, MMM d"
    let tempFormate = "%.0f°"

    //MARK: - funcs
    func configure(with data: SimpleDataWeather){
        guard let date = data.date,
              let temp = data.temp,
              let icon = data.icon else { return }
        
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: self.locale)
        dateFormatter.dateFormat = self.dateFormat
        self.date.text = dateFormatter.string(from: date)
        self.temperature.text = String(format: self.tempFormate, temp)
        self.icon.image = UIImage(systemName: icon)
    }
}
