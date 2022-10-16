//
//  ViewController.swift
//  weather
//
//  Created by Dmitriy Paranichev on 13.10.2022.
//

import UIKit
import CoreLocation

class ViewController: UIViewController {
    
    //MARK: - IBOutlets
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
    let counRowsForecast: Int = 5
    let rowHeight:CGFloat = 45
    let timeDaysForecast: String = "12"
    var array: [SimpleDataWeather] = []
    let colorNight = СolorNight()
    
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
                
                Manager.shared.lon = json.coord.lon
                Manager.shared.lat = json.coord.lat
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
        
        self.colorBGReplacement()

        Timer.scheduledTimer(withTimeInterval: 60, repeats: true) { timer in
            if LocationManager.shared.locationIsOn {
                LocationManager.shared.authLocation(for: self)
            }
            self.dataCurrentLoaded()
            self.dataForecastLoaded()
        }.fire()
    }
    
    //MARK: - funcs
    func colorBGReplacement() {
        self.colorNight.colorNightChanged(view: self.tableView, isNight: colorNight.loadNightData())
        self.colorNight.colorNightChanged(view: self.view, isNight: colorNight.loadNightData())
    }
    
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
            }
        }
    }
    
    func dataForecastLoaded() {
        Manager.shared.sendReqestForecast { [weak self] json in
            if let list = json.list as? [List] {
                self?.dataForecastChenged(for: list)
                DispatchQueue.main.async {
                    self?.tableView.reloadData()
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
                    if dateFormatter.string(from: date) == self.timeDaysForecast {
                        if let icon = elem.weather.first?.main {
                            let iconSystemName = self.iconChanged(icon: icon)
                            self.array.append(SimpleDataWeather(date: date, icon: iconSystemName, temp: elem.main.temp))
                        }
                    }
                }
            }
        }
    }
    
    @IBAction func settingButtonPresed(_ sender: UIButton) {
        guard let controller = self.storyboard?.instantiateViewController(withIdentifier: "SettingViewController") as? SettingViewController else { return }
        controller.delegate = self
        self.navigationController?.pushViewController(controller, animated: true)
    }
}

//MARK: - extensions
extension ViewController: UITableViewDelegate, UITableViewDataSource, CLLocationManagerDelegate, SettingViewControllerDelegate {
    func reqestForecast() {
        self.dataForecastLoaded()
    }
    
    func requestCurrent() {
        self.dataCurrentLoaded()
    }
    
    func VCWasClosed() {
        self.colorBGReplacement()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.counRowsForecast
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "WeatherTableViewCell", for: indexPath) as? WeatherTableViewCell else { return UITableViewCell() }
        if self.array.count > 0 {
            cell.configure(with: self.array[indexPath.row])
        }
        self.colorBGReplacement()
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return self.rowHeight
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let coordinate = manager.location?.coordinate else { return }
        let location: CLLocationCoordinate2D = coordinate
        
        Manager.shared.lon = location.longitude
        Manager.shared.lat = location.latitude
        LocationManager.shared.stopUpdatingLocation()
    }
}
