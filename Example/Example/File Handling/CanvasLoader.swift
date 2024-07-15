//
//  CanvasLoader.swift
//  Example
//
//  Created by Yannis De Cleene on 02/07/2024.
//

import Foundation
import JSONCanvas

import Foundation
import JSONCanvas

class CanvasLoader {
    static func load(from url: URL) throws -> JSONCanvas {
        do {
            let data = try Data(contentsOf: url)
            let decoder = JSONDecoder()
            return try decoder.decode(JSONCanvas.self, from: data)
        } catch {
            throw CanvasLoaderError.loadFailed(error)
        }
    }
    
    static func save(_ canvas: JSONCanvas, to url: URL) throws {
        do {
            let encoder = JSONEncoder()
            encoder.outputFormatting = .prettyPrinted
            let data = try encoder.encode(canvas)
            try data.write(to: url, options: .atomic)
        } catch {
            throw CanvasLoaderError.saveFailed(error)
        }
    }
    
    static func getDocumentsDirectory() -> URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }
    
    static func listCanvasFiles() -> [URL] {
        let documentsUrl = getDocumentsDirectory()
        let fileManager = FileManager.default
        
        do {
            let fileURLs = try fileManager.contentsOfDirectory(at: documentsUrl, includingPropertiesForKeys: nil, options: .skipsHiddenFiles)
            return fileURLs.filter { $0.pathExtension == "canvas" }
        } catch {
            print("Error while enumerating files: \(error.localizedDescription)")
            return []
        }
    }
    
    enum CanvasLoaderError: Error {
        case loadFailed(Error)
        case saveFailed(Error)
    }
}

