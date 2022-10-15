//
//  SettingViewController.swift
//  weather
//
//  Created by Dmitriy Paranichev on 14.10.2022.
//

import UIKit

protocol SettingViewControllerDelegate: AnyObject {
    func VCWasClosed()
    func reqestForecast()
    func requestCurrent()
}

class SettingViewController: UIViewController {
    
    weak var delegate: SettingViewControllerDelegate?

    //MARK: - let/var
    let colorNight = СolorNight()
    let rowHeigh:CGFloat = 60
    var array: [CityDataWeather] = []
    var counRowsCity: Int { array.count }
    
    //MARK: -IBOutlets
    @IBOutlet weak var cityTableView: UITableView!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var nightSwitch: UISwitch!
    @IBOutlet weak var nameCity: UILabel!
    @IBOutlet weak var nameState: UILabel!
    
    //MARK: - lifecycle funcs
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let dataCurrentWeather = UserDefaults.standard.data(forKey: "dataCurrentWeather") {
            do {
                let json = try JSONDecoder().decode(CurrentWeather.self, from: dataCurrentWeather)
                self.nameCity.text = json.name
                self.nameState.text = json.sys.country
            } catch {
                print(error)
            }
        }
        
        self.nightSwitch.isOn = colorNight.loadNightData()
        self.colorBGReplacement(isNight: colorNight.loadNightData())
    }
    
    //MARK: - funcs
    func colorBGReplacement(isNight: Bool) {
        self.colorNight.colorNightChanged(view: self.cityTableView, isNight: isNight)
        self.colorNight.colorNightChanged(view: self.view, isNight: isNight)
    }
    
    //MARK: - IBActions
    @IBAction func colorChangePressed(_ sender: UISwitch) {
        self.colorNight.saveNightData(isNight: sender.isOn)
        self.colorBGReplacement(isNight: sender.isOn)
    }
    
    @IBAction func cityTextRecruit(_ sender: UITextField) {
        if let text = sender.text,
           text.count > 1 {
            Manager.shared.sendReqestCityLocation(city: text, completion: { [weak self] json in
                self?.array.removeAll()
                for elem in json {
                    self?.array.append(CityDataWeather(city: elem.name, country: elem.country, lon: elem.lon, lat: elem.lat, state: elem.state))
                }
                DispatchQueue.main.async {
                    self?.cityTableView.reloadData()
                }
            })
        }
    }
    
    @IBAction func backButtonPressed(_ sender: UIButton) {
        delegate?.VCWasClosed()
        self.navigationController?.popToRootViewController(animated: true)
    }
}

//MARK: - extensions
extension SettingViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.counRowsCity
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "CityTableViewCell", for: indexPath) as? CityTableViewCell else { return UITableViewCell() }
        if self.array.count > 0 {
            cell.configure(with: self.array[indexPath.row])
        }
        self.colorBGReplacement(isNight: self.colorNight.loadNightData())
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return self.rowHeigh
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let elem = self.array[indexPath.row]

        guard let lon = elem.lon,
              let lat = elem.lat else { return }
        
        Manager.shared.lon = lon
        Manager.shared.lat = lat
        
        Manager.shared.sendReqestForecast { _ in
            DispatchQueue.main.async {
                self.delegate?.reqestForecast()
            }
        }
        Manager.shared.sendRequestCurrentWeather { _ in
            DispatchQueue.main.async {
                self.delegate?.requestCurrent()
            }
        }
        
        self.nameCity.text = elem.city
        self.nameState.text = elem.country
    }
}
