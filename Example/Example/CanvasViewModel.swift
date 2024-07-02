//
//  CanvasViewModel.swift
//  Example
//
//  Created by Yannis De Cleene on 02/07/2024.
//

import Foundation
import JSONCanvas
import SwiftUI

class CanvasViewModel: ObservableObject {
    @Published var canvas: JSONCanvas
    @Published var scale: CGFloat = 1.0
    @Published var offset: CGSize = .zero
    
    init() {
        let node1 = Node(id: "1", type: .text, x: 50, y: 50, width: 200, height: 100, color: .preset(1), text: "Hello, Canvas!")
        let node2 = Node(id: "2", type: .text, x: 300, y: 200, width: 200, height: 100, color: .preset(4), text: "This is node 2")
        let edge = CanvasEdge(id: "e1", fromNode: "1", toNode: "2", color: .hex("#000000"), label: "Connection")
        
        self.canvas = JSONCanvas(nodes: [node1, node2], edges: [edge])
    }
    
    func moveNode(id: String, by offset: CGSize) {
        if let index = canvas.nodes?.firstIndex(where: { $0.id == id }) {
            canvas.nodes?[index].x += Int(offset.width / scale)
            canvas.nodes?[index].y += Int(offset.height / scale)
        }
    }
}
