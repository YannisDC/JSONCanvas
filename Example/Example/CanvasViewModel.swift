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
    @Published var nodePositions: [String: CGPoint] = [:]
    @Published var canvasFiles: [URL] = []
    
    init() {
        self.canvas = JSONCanvas(nodes: [], edges: [])
//        loadSampleCanvas()
        refreshCanvasFileList()
    }
    
    private func loadSampleCanvas() {
        let node1 = CanvasNode(id: "1", type: .text, x: 50, y: 50, width: 200, height: 100, color: .preset(1), text: "Hello, Canvas!")
        let node2 = CanvasNode(id: "2", type: .text, x: 300, y: 200, width: 200, height: 100, color: .preset(4), text: "This is node 2")
        let edge = CanvasEdge(id: "e1", fromNode: "1", toNode: "2", color: .hex("#0000FF"), label: "Connection")
        
        self.canvas = JSONCanvas(nodes: [node1, node2], edges: [edge])
        updateNodePositions()
    }
    
    func updateNodePositions() {
        for node in canvas.nodes ?? [] {
            nodePositions[node.id] = CGPoint(x: node.x, y: node.y)
        }
    }
    
    func updateNodePosition(id: String, position: CGPoint) {
        nodePositions[id] = position
    }
    
    func finalizeNodePosition(id: String) {
        guard let position = nodePositions[id],
              let index = canvas.nodes?.firstIndex(where: { $0.id == id }) else {
            return
        }
        
        canvas.nodes?[index].x = Int(position.x)
        canvas.nodes?[index].y = Int(position.y)
    }
    
    func loadCanvas(from url: URL) {
        do {
            self.canvas = try CanvasLoader.load(from: url)
            updateNodePositions()
        } catch {
            print("Error loading canvas: \(error)")
        }
    }
    
    func saveCanvas(as fileName: String) {
        let fileURL = CanvasLoader.getDocumentsDirectory().appendingPathComponent(fileName).appendingPathExtension("canvas")
        do {
            try CanvasLoader.save(canvas, to: fileURL)
            refreshCanvasFileList()
        } catch {
            print("Error saving canvas: \(error)")
        }
    }
    
    func refreshCanvasFileList() {
        canvasFiles = CanvasLoader.listCanvasFiles()
    }
}
