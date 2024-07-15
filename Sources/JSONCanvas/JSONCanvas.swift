//
//  CanvasView.swift
//  Example
//
//  Created by Yannis De Cleene on 02/07/2024.
//

import Foundation
import UIKit

public struct JSONCanvas: Codable {
    public var nodes: [CanvasNode]?
    public var edges: [CanvasEdge]?
    
    public init(nodes: [CanvasNode]? = nil, edges: [CanvasEdge]? = nil) {
        self.nodes = nodes
        self.edges = edges
    }
}

public enum NodeType: String, Codable {
    case text
    case file
    case link
    case group
}

public struct CanvasNode: Codable {
    public let id: String
    public let type: NodeType
    public var x: Int
    public var y: Int
    public let width: Int
    public let height: Int
    public let color: CanvasColor?
    
    // Text node
    public let text: String?
    
    // File node
    public let file: String?
    public let subpath: String?
    
    // Link node
    public let url: String?
    
    // Group node
    public let label: String?
    public let background: String?
    public let backgroundStyle: BackgroundStyle?
    
    public init(
        id: String,
        type: NodeType,
        x: Int, 
        y: Int,
        width: Int, 
        height: Int,
        color: CanvasColor? = nil,
        text: String? = nil,
        file: String? = nil,
        subpath: String? = nil,
        url: String? = nil,
        label: String? = nil,
        background: String? = nil,
        backgroundStyle: BackgroundStyle? = nil
    ) {
        self.id = id
        self.type = type
        self.x = x
        self.y = y
        self.width = width
        self.height = height
        self.color = color
        self.text = text
        self.file = file
        self.subpath = subpath
        self.url = url
        self.label = label
        self.background = background
        self.backgroundStyle = backgroundStyle
    }
}

public enum BackgroundStyle: String, Codable {
    case cover
    case ratio
    case `repeat`
}

public struct CanvasEdge: Codable {
    public let id: String
    public let fromNode: String
    public let fromSide: Side?
    public let fromEnd: EndpointShape?
    public let toNode: String
    public let toSide: Side?
    public let toEnd: EndpointShape?
    public let color: CanvasColor?
    public let label: String?
    
    public init(id: String, fromNode: String, fromSide: Side? = nil, fromEnd: EndpointShape? = nil,
                toNode: String, toSide: Side? = nil, toEnd: EndpointShape? = .arrow,
                color: CanvasColor? = nil, label: String? = nil) {
        self.id = id
        self.fromNode = fromNode
        self.fromSide = fromSide
        self.fromEnd = fromEnd
        self.toNode = toNode
        self.toSide = toSide
        self.toEnd = toEnd
        self.color = color
        self.label = label
    }
}

public enum Side: String, Codable {
    case top
    case right
    case bottom
    case left
}

public enum EndpointShape: String, Codable {
    case none
    case arrow
}

public enum CanvasColor: Codable, Equatable {
    case hex(String)
    case preset(Int)
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let value = try container.decode(String.self)
        
        if value.hasPrefix("#") {
            // Validate hex color format
            let hexPattern = "^#([A-Fa-f0-9]{6}|[A-Fa-f0-9]{3})$"
            let hexRegex = try! NSRegularExpression(pattern: hexPattern, options: [])
            let range = NSRange(location: 0, length: value.utf16.count)
            
            if hexRegex.firstMatch(in: value, options: [], range: range) != nil {
                self = .hex(value)
            } else {
                throw DecodingError.dataCorruptedError(in: container, debugDescription: "Invalid hex color format")
            }
        } else if let presetValue = Int(value), (1...6).contains(presetValue) {
            self = .preset(presetValue)
        } else {
            throw DecodingError.dataCorruptedError(in: container, debugDescription: "Invalid color value")
        }
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .hex(let value):
            try container.encode(value)
        case .preset(let value):
            try container.encode(String(value))
        }
    }
    
    public static func == (lhs: CanvasColor, rhs: CanvasColor) -> Bool {
        switch (lhs, rhs) {
        case (.hex(let lhsValue), .hex(let rhsValue)):
            return lhsValue == rhsValue
        case (.preset(let lhsValue), .preset(let rhsValue)):
            return lhsValue == rhsValue
        default:
            return false
        }
    }
    
    public var uiColor: UIColor {
        switch self {
        case .hex(let hexString):
            return UIColor(hex: hexString) ?? .gray
        case .preset(let value):
            return UIColor(named: "Preset\(value)") ?? .gray
        }
    }
}

extension UIColor {
    convenience init?(hex: String) {
        let r, g, b, a: CGFloat

        if hex.hasPrefix("#") {
            let start = hex.index(hex.startIndex, offsetBy: 1)
            let hexColor = String(hex[start...])

            if hexColor.count == 6 {
                let scanner = Scanner(string: hexColor)
                var hexNumber: UInt64 = 0

                if scanner.scanHexInt64(&hexNumber) {
                    r = CGFloat((hexNumber & 0xff0000) >> 16) / 255
                    g = CGFloat((hexNumber & 0x00ff00) >> 8) / 255
                    b = CGFloat(hexNumber & 0x0000ff) / 255
                    a = 1.0

                    self.init(red: r, green: g, blue: b, alpha: a)
                    return
                }
            }
        }

        return nil
    }
}
