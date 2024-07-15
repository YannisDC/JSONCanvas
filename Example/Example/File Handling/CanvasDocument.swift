//
//  CanvasDocument.swift
//  Example
//
//  Created by Yannis De Cleene on 02/07/2024.
//

import SwiftUI
import JSONCanvas
import UniformTypeIdentifiers

struct CanvasDocument: FileDocument {
    var canvas: JSONCanvas

    static var readableContentTypes: [UTType] { [UTType(filenameExtension: "canvas")!] }

    init(canvas: JSONCanvas) {
        self.canvas = canvas
    }

    init(configuration: ReadConfiguration) throws {
        guard let data = configuration.file.regularFileContents,
              let canvas = try? JSONDecoder().decode(JSONCanvas.self, from: data)
        else {
            throw CocoaError(.fileReadCorruptFile)
        }
        self.canvas = canvas
    }

    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        let data = try JSONEncoder().encode(canvas)
        return FileWrapper(regularFileWithContents: data)
    }
}
