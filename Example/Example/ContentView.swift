//
//  ContentView.swift
//  Example
//
//  Created by Yannis De Cleene on 02/07/2024.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = CanvasViewModel()
    
    var body: some View {
        CanvasView(viewModel: viewModel)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

#Preview {
    ContentView()
}
