//
//  CanvasView.swift
//  Example
//
//  Created by Yannis De Cleene on 02/07/2024.
//

import SwiftUI
import JSONCanvas

struct CanvasView: View {
    @ObservedObject var viewModel: CanvasViewModel
    @GestureState private var dragOffset: CGSize = .zero
    @State private var isPinching: Bool = false
    @GestureState private var scaleState: CGFloat = 1.0
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Color.white
                
                // Draw edges
                ForEach(viewModel.canvas.edges ?? [], id: \.id) { edge in
                    EdgeView(edge: edge, nodes: viewModel.canvas.nodes ?? [])
                }
                
                // Draw nodes
                ForEach(viewModel.canvas.nodes ?? [], id: \.id) { node in
                    NodeView(viewModel: viewModel, node: node)
                }
            }
            .scaleEffect(viewModel.scale * scaleState)
            .offset(x: viewModel.offset.width + dragOffset.width,
                    y: viewModel.offset.height + dragOffset.height)
            .gesture(
                DragGesture()
                    .updating($dragOffset) { value, state, _ in
                        state = value.translation
                    }
                    .onEnded { value in
                        viewModel.offset = CGSize(
                            width: viewModel.offset.width + value.translation.width,
                            height: viewModel.offset.height + value.translation.height
                        )
                    }
            )
            .gesture(
                MagnificationGesture()
                    .updating($scaleState) { value, state, _ in
                        state = value.magnitude
                    }
                    .onChanged { _ in
                        isPinching = true
                    }
                    .onEnded { value in
                        viewModel.scale *= value.magnitude
                        isPinching = false
                    }
            )
            .animation(.interactiveSpring(), value: isPinching)
            .onTapGesture(count: 2) {
                withAnimation(.spring()) {
                    viewModel.scale = 1.0
                    viewModel.offset = .zero
                }
            }
        }
    }
}


struct EdgeView: View {
    let edge: CanvasEdge
    let nodes: [Node]
    
    var body: some View {
        GeometryReader { geometry in
            Path { path in
                guard let fromNode = nodes.first(where: { $0.id == edge.fromNode }),
                      let toNode = nodes.first(where: { $0.id == edge.toNode }) else {
                    return
                }
                
                let start = CGPoint(x: CGFloat(fromNode.x), y: CGFloat(fromNode.y))
                let end = CGPoint(x: CGFloat(toNode.x), y: CGFloat(toNode.y))
                
                path.move(to: start)
                path.addLine(to: end)
            }
            .stroke(edgeColor, lineWidth: 2)
        }
    }
    
    var edgeColor: Color {
        switch edge.color {
        case .preset(let value):
            return Color("Preset\(value)")
        case .hex(let value):
            return Color(.red)
        case .none:
            return Color.black
        }
    }
}

struct NodeView: View {
    @ObservedObject var viewModel: CanvasViewModel
    let node: Node
    @GestureState private var dragOffset: CGSize = .zero
    @State private var position: CGSize = .zero
    
    var body: some View {
        Text(node.text ?? "")
            .padding()
            .frame(width: CGFloat(node.width), height: CGFloat(node.height))
            .background(nodeColor)
            .cornerRadius(8)
            .position(x: CGFloat(node.x) + position.width,
                      y: CGFloat(node.y) + position.height)
            .gesture(
                DragGesture()
                    .updating($dragOffset) { value, state, _ in
                        state = value.translation
                    }
                    .onChanged { value in
                        position = CGSize(
                            width: value.translation.width / viewModel.scale,
                            height: value.translation.height / viewModel.scale
                        )
                    }
                    .onEnded { value in
                        viewModel.moveNode(id: node.id, by: position)
                        position = .zero
                    }
            )
    }
    
    var nodeColor: Color {
        switch node.color {
        case .preset(let value):
            return Color("Preset\(value)")
        case .hex(let value):
            return Color(.red)
        case .none:
            return Color.gray
        }
    }
}


extension CGSize {
    static func + (lhs: CGSize, rhs: CGSize) -> CGSize {
        return CGSize(width: lhs.width + rhs.width, height: lhs.height + rhs.height)
    }
}
