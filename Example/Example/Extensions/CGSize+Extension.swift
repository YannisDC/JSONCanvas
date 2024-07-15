//
//  CGSize+Extension.swift
//  Example
//
//  Created by Yannis De Cleene on 02/07/2024.
//

import Foundation

extension CGSize {
    static func + (lhs: CGSize, rhs: CGSize) -> CGSize {
        return CGSize(width: lhs.width + rhs.width, height: lhs.height + rhs.height)
    }
}
