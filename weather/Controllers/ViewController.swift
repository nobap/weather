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
    var array: [SimpleDataWeather] = []
    let colorNight = СolorNight()
    let rowHeight:CGFloat = 45
    let counRowsForecast: Int = 5
    let timeDaysForecast: String = "12"
    let timeDaysFormatForecast: String = "HH"
    let dateFormatForecast = "yyyy-MM-dd HH:mm:ss"
    let weatherTempFormat = "%.0f°"
    let weatherWindFormat = "%.0f" + "m/s".localized
    let weatherHumiditySuffix = "%"
    let weatherPressureSuffix = "hPa".localized
    
    //MARK: - lifecycle funcs
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //        Manager.shared.removeWeatherData()
        
        self.mainLoadCurrentWeatherData()
        self.mainLoadForecastWeatherData()
        
        self.colorBGReplacement()
        
        Timer.scheduledTimer(withTimeInterval: 180, repeats: true) { timer in
            if LocationManager.shared.locationIsOn {
                LocationManager.shared.authLocation(for: self)
            }
            self.dataCurrentLoaded()
            self.dataForecastLoaded()
        }.fire()
    }
    
    //MARK: - funcs
    func mainLoadCurrentWeatherData() {
        if let dataCurrentWeather = Manager.shared.loadCurrentWeatherData() {
            do {
                let json = try JSONDecoder().decode(CurrentWeather.self, from: dataCurrentWeather)
                guard let descr = json.weather.first?.description,
                      let icon = json.weather.first?.icon else { return }
                self.dataChenged(city: json.name, country: json.sys.country, icon: icon, temp: json.main.temp, descriptoin: descr, wind: json.wind.speed, humidity: json.main.humidity, pressure: json.main.pressure)
                
                Manager.shared.lon = json.coord.lon
                Manager.shared.lat = json.coord.lat
            } catch {
                print(error)
            }
        }
    }
    
    func mainLoadForecastWeatherData() {
        if let dataForecastWeather = Manager.shared.loadForecastWeatherData() {
            do {
                let json = try JSONDecoder().decode(ForecastWeather.self, from: dataForecastWeather)
                if let list = json.list as? [List] {
                    self.dataForecastChenged(for: list)
                }
            } catch {
                print(error)
            }
        }
    }
    
    func colorBGReplacement() {
        self.colorNight.colorNightChanged(view: self.tableView, isNight: colorNight.loadNightData())
        self.colorNight.colorNightChanged(view: self.view, isNight: colorNight.loadNightData())
    }
    
    func dataChenged(city: String, country: String, icon: String, temp: Double, descriptoin: String, wind: Double, humidity: Int, pressure: Int) {
        self.weatherCity.text = city
        self.weatherCountry.text = country
        self.iconChangedImage(icon: icon)
        self.weatherTemp.text = String(format: self.weatherTempFormat, temp)
        self.weatherDescription.text = descriptoin.firstCapitalized
        self.weatherWind.text = String(format: self.weatherWindFormat, wind)
        self.weatherHumidity.text = "\(humidity)\(self.weatherHumiditySuffix)"
        self.weatherPressure.text = "\(pressure)\(self.weatherPressureSuffix)"
    }
    
    func iconChangedImage(icon: String) {
        let iconSystemName = self.iconChanged(icon: icon)
        self.weatherIcon.image = UIImage(systemName: iconSystemName)
    }
    
    func iconChanged(icon: String) -> String {
        switch icon {
        case "01d":
            return "sun.min"
        case "01n":
            return "moon.stars"
        case "02d":
            return "cloud.sun"
        case "02n":
            return "cloud.moon"
        case "03d", "03n":
            return "cloud"
        case "04d", "04n":
            return "smoke"
        case "09d", "09n":
            return "cloud.drizzle"
        case "10d":
            return "cloud.sun.rain"
        case "10n":
            return "cloud.moon.rain"
        case "11d", "11n":
            return "cloud.bolt.rain"
        case "13d", "13n":
            return "cloud.snow"
        case "50d", "50n":
            return "cloud.fog"
        default:
            return "sun.min"
        }
    }
    
    func dataCurrentLoaded() {
        Manager.shared.sendRequestCurrentWeather { [weak self] json in
            DispatchQueue.main.async {
                guard let descr = json.weather.first?.description,
                      let icon = json.weather.first?.icon else { return }
                self?.dataChenged(city: json.name, country: json.sys.country, icon: icon, temp: json.main.temp, descriptoin: descr, wind: json.wind.speed, humidity: json.main.humidity, pressure: json.main.pressure)
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
        self.array.removeAll()
        for elem in list {
            if let dateString = elem.dt_txt {
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = self.dateFormatForecast
                
                if let date = dateFormatter.date(from: dateString) {
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = self.timeDaysFormatForecast
                    if dateFormatter.string(from: date) == self.timeDaysForecast {
                        if let icon = elem.weather.first?.icon {
                            let iconSystemName = self.iconChanged(icon: icon)
                            self.array.append(SimpleDataWeather(date: date, icon: iconSystemName, temp: elem.main.temp))
                        }
                    }
                }
            }
        }
    }
    
    //MARK: - IBActions
    @IBAction func settingButtonPresed(_ sender: UIButton) {
        guard let controller = self.storyboard?.instantiateViewController(withIdentifier: "SettingViewController") as? SettingViewController else { return }
        controller.delegate = self
        self.navigationController?.pushViewController(controller, animated: true)
    }
}

//MARK: - extensions
extension ViewController: UITableViewDelegate, UITableViewDataSource, CLLocationManagerDelegate, SettingViewControllerDelegate {
    func requestCurrent() {
        self.mainLoadCurrentWeatherData()
    }
    
    func reqestForecast() {
        self.mainLoadForecastWeatherData()
        self.tableView.reloadData()
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
