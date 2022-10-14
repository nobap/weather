//
//  StringProtocol+extensions.swift
//  weather
//
//  Created by Dmitriy Paranichev on 13.10.2022.
//

import Foundation

extension StringProtocol {
    var firstUppercased: String { prefix(1).uppercased() + dropFirst() }
    var firstCapitalized: String { prefix(1).capitalized + dropFirst() }
}
