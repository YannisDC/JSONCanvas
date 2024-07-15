//
//  Color+Extension.swift
//  Example
//
//  Created by Yannis De Cleene on 02/07/2024.
//

import SwiftUI

extension Color {
    init(uiColor: UIColor) {
        self.init(red: Double(uiColor.cgColor.components?[0] ?? 0),
                  green: Double(uiColor.cgColor.components?[1] ?? 0),
                  blue: Double(uiColor.cgColor.components?[2] ?? 0),
                  opacity: Double(uiColor.cgColor.components?[3] ?? 1))
    }
}
