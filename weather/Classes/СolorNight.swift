//
//  СolorNight.swift
//  weather
//
//  Created by Dmitriy Paranichev on 14.10.2022.
//

import Foundation
import UIKit

enum СolorNightKeys: String {
    case isNight
}

class СolorNight {
    let bgColorDay = UIColor(red: 226/255.0, green: 234/255.0, blue: 242/255.0, alpha: 1.0)
    let bgColorNight = UIColor(red: 47/255.0, green: 54/255.0, blue: 67/255.0, alpha: 1.0)
    var textColorDay: UIColor { bgColorNight }
    var textColorNight: UIColor { bgColorDay }
    var isNight: Bool {
        return loadNightData() ? loadNightData() : false
    }
    
    func colorNightChanged(view: UIView, isNight: Bool) {
        if isNight {
            self.colorChanged(view: view, bgColor: bgColorNight, textColor: textColorNight)
        } else {
            self.colorChanged(view: view, bgColor: bgColorDay, textColor: textColorDay)
        }
    }
    
    func colorChanged(view: UIView, bgColor: UIColor, textColor: UIColor) {
        view.backgroundColor = bgColor
        
        let buttons = self.getButtonsInView(view: view)
        for button in buttons {
            button.tintColor = textColor
        }
        
        let labels = self.getLabelsInView(view: view)
        for label in labels {
            label.textColor = textColor
        }

        let images = self.getImagesInView(view: view)
        for image in images {
            image.tintColor = textColor
        }
    }
    
    func saveNightData(isNight: Bool) {
        UserDefaults.standard.set(isNight, forKey: СolorNightKeys.isNight.rawValue)
    }
    
    func loadNightData() -> Bool {
        guard let night = UserDefaults.standard.value(forKey: СolorNightKeys.isNight.rawValue) as? Bool else { return self.isNight }
        return night
    }
    
    func getLabelsInView(view: UIView) -> [UILabel] {
        var results = [UILabel]()
        for subview in view.subviews as [UIView] {
            if let labelView = subview as? UILabel {
                results += [labelView]
            } else {
                results += getLabelsInView(view: subview)
            }
        }
        return results
    }
    
    func getButtonsInView(view: UIView) -> [UIButton] {
        var results = [UIButton]()
        for subview in view.subviews as [UIView] {
            if let buttonView = subview as? UIButton {
                results += [buttonView]
            } else {
                results += getButtonsInView(view: subview)
            }
        }
        return results
    }
    
    func getImagesInView(view: UIView) -> [UIImageView] {
        var results = [UIImageView]()
        for subview in view.subviews as [UIView] {
            if let imageView = subview as? UIImageView {
                results += [imageView]
            } else {
                results += getImagesInView(view: subview)
            }
        }
        return results
    }
}
