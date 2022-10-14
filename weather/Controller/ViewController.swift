//
//  ViewController.swift
//  weather
//
//  Created by Dmitriy Paranichev on 13.10.2022.
//

import UIKit

class ViewController: UIViewController {
    
    //MARK: -IBOutlets
    @IBOutlet weak var weatherCity: UILabel!
    @IBOutlet weak var weatherCountry: UILabel!
    @IBOutlet weak var weatherIcon: UIImageView!
    @IBOutlet weak var weatherTemp: UILabel!
    @IBOutlet weak var weatherDescription: UILabel!
    @IBOutlet weak var weatherWind: UILabel!
    @IBOutlet weak var weatherHumidity: UILabel!
    @IBOutlet weak var weatherPressure: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    //MARK: - let/var
    let counRowsForecast = 4
    var array: [SimpleDataWeather] = []

    //MARK: - lifecycle funcs
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        UserDefaults.standard.removeObject(forKey: "dataCurrentWeather")
//        UserDefaults.standard.removeObject(forKey: "dataForecastWeather")

        if let dataCurrentWeather = UserDefaults.standard.data(forKey: "dataCurrentWeather") {
            do {
                let json = try JSONDecoder().decode(CurrentWeather.self, from: dataCurrentWeather)
                guard let descr = json.weather.first?.description,
                      let main = json.weather.first?.main else { return }
                self.dataChenged(city: json.name, country: json.sys.country, icon: main, temp: json.main.temp, descriptoin: descr, wind: json.wind.speed, humidity: json.main.humidity, pressure: json.main.pressure)
            } catch {
                print(error)
            }
        }

        if let dataForecastWeather = UserDefaults.standard.data(forKey: "dataForecastWeather") {
            do {
                let json = try JSONDecoder().decode(ForecastWeather.self, from: dataForecastWeather)
                if let list = json.list as? [List] {
                    self.dataForecastChenged(for: list)
                }
            } catch {
                print(error)
            }
        }
                
        self.dataCurrentLoaded()
        self.dataForecastLoaded()
    }
    
    //MARK: - funcs
    func dataChenged(city: String, country: String, icon: String, temp: Double, descriptoin: String, wind: Double, humidity: Int, pressure: Int) {
        self.weatherCity.text = city
        self.weatherCountry.text = country
        self.iconChangedImage(icon: icon)
        self.weatherTemp.text = String(format: "%.0f°", temp)
        self.weatherDescription.text = descriptoin.firstCapitalized
        self.weatherWind.text = String(format: "%.0fm/s", wind)
        self.weatherHumidity.text = "\(humidity)%"
        self.weatherPressure.text = "\(pressure)hPa"
    }
    
    func iconChangedImage(icon: String) {
        let iconSystemName = self.iconChanged(icon: icon)
        self.weatherIcon.image = UIImage(systemName: iconSystemName)
    }
    
    func iconChanged(icon: String) -> String {
        switch icon {
        case "Clear":
            return "sun.min"
        case "Clouds":
            return "cloud.sun"
        case "Drizzle":
            return "cloud.drizzle"
        case "Rain":
            return "cloud.rain"
        case "Thunderstorm":
            return "cloud.bolt.rain"
        case "Snow":
            return "snow"
        case "Mist":
            return "cloud.fog"
        case "Smoke":
            return "smoke"
        case "Haze":
            return "sun.haze"
        case "Dust":
            return "sun.dust"
        case "Fog", "Sand", "Ash", "Squall":
            return "cloud.fog"
        case "Tornado":
            return "tornado"
        default:
            return "sun.min"
        }
    }

    func dataCurrentLoaded() {
        Manager.shared.sendRequestCurrentWeather { [weak self] json in
            DispatchQueue.main.async {
                guard let descr = json.weather.first?.description,
                      let main = json.weather.first?.main else { return }
                self?.dataChenged(city: json.name, country: json.sys.country, icon: main, temp: json.main.temp, descriptoin: descr, wind: json.wind.speed, humidity: json.main.humidity, pressure: json.main.pressure)

                Timer.scheduledTimer(withTimeInterval: 30, repeats: true) { timer in
                    self?.dataCurrentLoaded()
                    timer.invalidate()
                }
            }
        }
    }
        
    func dataForecastLoaded() {
        Manager.shared.sendReqestForecast { [weak self] json in
            if let list = json.list as? [List] {
                self?.dataForecastChenged(for: list)
                DispatchQueue.main.async {
                    self?.tableView.reloadData()
                    
                    Timer.scheduledTimer(withTimeInterval: 120, repeats: true) { timer in
                        self?.dataForecastLoaded()
                        timer.invalidate()
                    }
                }
            }
        }
    }
    
    func dataForecastChenged(for list: [List]) {
        for elem in list {
            if let dateString = elem.dt_txt {
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"

                if let date = dateFormatter.date(from: dateString) {
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "HH"
                    if dateFormatter.string(from: date) == "09" {
                        if let icon = elem.weather.first?.main {
                            let iconSystemName = self.iconChanged(icon: icon)
                            self.array.append(SimpleDataWeather(date: date, icon: iconSystemName, temp: elem.main.temp))
                        }
                    }
                }
            }
        }
    }
}

//MARK: - extensions
extension ViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.counRowsForecast
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "WeatherTableViewCell", for: indexPath) as? WeatherTableViewCell else { return UITableViewCell() }
        
        if self.array.count > 0 {
            cell.configure(with: self.array[indexPath.row])
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 45
    }
}
