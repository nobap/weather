//
//  String+extensions.swift
//  weather
//
//  Created by Dmitriy Paranichev on 18.10.2022.
//

import Foundation

extension String {
    var localized: String {
        NSLocalizedString(self, comment: "")
    }
}
