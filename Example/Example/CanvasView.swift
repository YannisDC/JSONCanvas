//
//  CanvasView.swift
//  Example
//
//  Created by Yannis De Cleene on 02/07/2024.
//

import SwiftUI
import JSONCanvas
import UniformTypeIdentifiers

struct CanvasView: View {
    @ObservedObject var viewModel: CanvasViewModel
    @GestureState private var dragOffset: CGSize = .zero
    @State private var isPinching: Bool = false
    @GestureState private var scaleState: CGFloat = 1.0
    @State private var isLoadingPresented = false
        @State private var isSavingPresented = false
    
    var body: some View {
        ZStack {
            GeometryReader { geometry in
                ZStack {
                    Color.yellow
                    
                    // Draw edges
                    ForEach(viewModel.canvas.edges ?? [], id: \.id) { edge in
                        EdgeView(viewModel: viewModel, edge: edge)
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
            
            VStack {
                Spacer()
                
                VStack(spacing: 16) {
                    Button(action: {
                        viewModel.refreshCanvasFileList()
                                            isLoadingPresented = true
                    }) {
                        Label("Open Canvas", systemImage: "folder")
                            .frame(minWidth: 150)
                    }
                    .buttonStyle(.borderedProminent)
                    .controlSize(.large)
                    
                    Button(action: {
                        isSavingPresented = true
                    }) {
                        Label("Save Canvas", systemImage: "square.and.arrow.down")
                            .frame(minWidth: 150)
                    }
                    .buttonStyle(.borderedProminent)
                    .controlSize(.large)
                }
            }
        }
        .sheet(isPresented: $isLoadingPresented) {
            CanvasFilePicker(viewModel: viewModel, isPresented: $isLoadingPresented)
        }
        .sheet(isPresented: $isSavingPresented) {
            SaveCanvasView(viewModel: viewModel, isPresented: $isSavingPresented)
        }
    }
}

struct EdgeView: View {
    @ObservedObject var viewModel: CanvasViewModel
    let edge: CanvasEdge
    
    var body: some View {
        GeometryReader { geometry in
            Path { path in
                guard let start = viewModel.nodePositions[edge.fromNode],
                      let end = viewModel.nodePositions[edge.toNode] else {
                    return
                }
                
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
            let canvasColor: CanvasColor = .hex(value)
            return Color(uiColor: canvasColor.uiColor)
        case .none:
            return Color.black
        }
    }
}

struct NodeView: View {
    @ObservedObject var viewModel: CanvasViewModel
    let node: CanvasNode
    @State private var dragOffset: CGSize = .zero
    
    var body: some View {
        Text(node.text ?? "")
            .padding()
            .frame(width: CGFloat(node.width), height: CGFloat(node.height))
            .background(nodeColor)
            .cornerRadius(8)
            .position(nodePosition)
            .gesture(
                DragGesture()
                    .onChanged { value in
                        let newPosition = CGPoint(
                            x: CGFloat(node.x) + value.translation.width / viewModel.scale,
                            y: CGFloat(node.y) + value.translation.height / viewModel.scale
                        )
                        viewModel.updateNodePosition(id: node.id, position: newPosition)
                        dragOffset = value.translation
                    }
                    .onEnded { _ in
                        viewModel.finalizeNodePosition(id: node.id)
                        dragOffset = .zero
                    }
            )
    }
    
    var nodePosition: CGPoint {
        viewModel.nodePositions[node.id] ?? CGPoint(x: node.x, y: node.y)
    }
    
    var nodeColor: Color {
        switch node.color {
        case .preset(let value):
            return Color("Preset\(value)")
        case .hex(let value):
            let canvasColor: CanvasColor = .hex(value)
            return Color(uiColor: canvasColor.uiColor)
        case .none:
            return Color.gray
        }
    }
}

struct CanvasFilePicker: View {
    @ObservedObject var viewModel: CanvasViewModel
    @Binding var isPresented: Bool
    
    var body: some View {
        NavigationView {
            List(viewModel.canvasFiles, id: \.self) { file in
                Button(action: {
                    viewModel.loadCanvas(from: file)
                    isPresented = false
                }) {
                    Text(file.lastPathComponent)
                }
            }
            .navigationTitle("Load Canvas")
            .navigationBarItems(trailing: Button("Cancel") {
                isPresented = false
            })
        }
    }
}

struct SaveCanvasView: View {
    @ObservedObject var viewModel: CanvasViewModel
    @Binding var isPresented: Bool
    @State private var fileName: String = ""
    
    var body: some View {
        NavigationView {
            Form {
                TextField("File Name", text: $fileName)
                Button("Save") {
                    viewModel.saveCanvas(as: fileName)
                    isPresented = false
                }
            }
            .navigationTitle("Save Canvas")
            .navigationBarItems(trailing: Button("Cancel") {
                isPresented = false
            })
        }
    }
}
