import XCTest
@testable import JSONCanvas

final class JSONCanvasTests: XCTestCase {
    func testNodeCreation() {
        let node = Node(id: "1", type: .text, x: 10, y: 20, width: 100, height: 50, color: .preset(1), text: "Hello, world!")
        XCTAssertEqual(node.id, "1")
        XCTAssertEqual(node.type, .text)
        XCTAssertEqual(node.x, 10)
        XCTAssertEqual(node.y, 20)
        XCTAssertEqual(node.width, 100)
        XCTAssertEqual(node.height, 50)
        XCTAssertEqual(node.color, .preset(1))
        XCTAssertEqual(node.text, "Hello, world!")
    }
    
    func testEdgeCreation() {
        let edge = CanvasEdge(id: "e1", fromNode: "1", toNode: "2", color: .hex("#FF0000"), label: "Connection")
        XCTAssertEqual(edge.id, "e1")
        XCTAssertEqual(edge.fromNode, "1")
        XCTAssertEqual(edge.toNode, "2")
        XCTAssertEqual(edge.color, .hex("#FF0000"))
        XCTAssertEqual(edge.label, "Connection")
    }
    
    func testJSONCanvasCreation() {
        let node = Node(id: "1", type: .text, x: 10, y: 20, width: 100, height: 50, text: "Hello")
        let edge = CanvasEdge(id: "e1", fromNode: "1", toNode: "2")
        let canvas = JSONCanvas(nodes: [node], edges: [edge])
        
        XCTAssertEqual(canvas.nodes?.count, 1)
        XCTAssertEqual(canvas.edges?.count, 1)
    }
    
    func testJSONDecoding() throws {
        let jsonString = """
        {
            "nodes": [
                {
                    "id": "1",
                    "type": "text",
                    "x": 100,
                    "y": 200,
                    "width": 300,
                    "height": 150,
                    "color": "1",
                    "text": "Hello, JSON!"
                },
                {
                    "id": "2",
                    "type": "file",
                    "x": 500,
                    "y": 300,
                    "width": 200,
                    "height": 100,
                    "color": "#00FF00",
                    "file": "document.pdf"
                }
            ],
            "edges": [
                {
                    "id": "e1",
                    "fromNode": "1",
                    "toNode": "2",
                    "color": "3",
                    "label": "Connection"
                }
            ]
        }
        """
        
        let jsonData = jsonString.data(using: .utf8)!
        let decoder = JSONDecoder()
        let canvas = try decoder.decode(JSONCanvas.self, from: jsonData)
        
        XCTAssertEqual(canvas.nodes?.count, 2)
        XCTAssertEqual(canvas.edges?.count, 1)
        
        let firstNode = canvas.nodes?[0]
        XCTAssertEqual(firstNode?.id, "1")
        XCTAssertEqual(firstNode?.type, .text)
        XCTAssertEqual(firstNode?.x, 100)
        XCTAssertEqual(firstNode?.y, 200)
        XCTAssertEqual(firstNode?.width, 300)
        XCTAssertEqual(firstNode?.height, 150)
        XCTAssertEqual(firstNode?.color, .preset(1))
        XCTAssertEqual(firstNode?.text, "Hello, JSON!")
        
        let secondNode = canvas.nodes?[1]
        XCTAssertEqual(secondNode?.id, "2")
        XCTAssertEqual(secondNode?.type, .file)
        XCTAssertEqual(secondNode?.color, .hex("#00FF00"))
        XCTAssertEqual(secondNode?.file, "document.pdf")
        
        let edge = canvas.edges?[0]
        XCTAssertEqual(edge?.id, "e1")
        XCTAssertEqual(edge?.fromNode, "1")
        XCTAssertEqual(edge?.toNode, "2")
        XCTAssertEqual(edge?.color, .preset(3))
        XCTAssertEqual(edge?.label, "Connection")
    }
    
    func testJSONEncoding() throws {
        let node1 = Node(id: "1", type: .text, x: 100, y: 200, width: 300, height: 150, color: .preset(1), text: "Hello, JSON!")
        let node2 = Node(id: "2", type: .file, x: 500, y: 300, width: 200, height: 100, color: .hex("#00FF00"), file: "document.pdf")
        let edge = CanvasEdge(id: "e1", fromNode: "1", toNode: "2", color: .preset(3), label: "Connection")
        
        let canvas = JSONCanvas(nodes: [node1, node2], edges: [edge])
        
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        let jsonData = try encoder.encode(canvas)
        let jsonString = String(data: jsonData, encoding: .utf8)!
        
        // Print the JSON string for visual inspection
        print("Encoded JSON:\n\(jsonString)")
        
        // Decode the JSON string back to a JSONCanvas object
        let decoder = JSONDecoder()
        let decodedCanvas = try decoder.decode(JSONCanvas.self, from: jsonData)
        
        // Compare the original and decoded canvas
        XCTAssertEqual(decodedCanvas.nodes?.count, canvas.nodes?.count)
        XCTAssertEqual(decodedCanvas.edges?.count, canvas.edges?.count)
        
        XCTAssertEqual(decodedCanvas.nodes?[0].id, "1")
        XCTAssertEqual(decodedCanvas.nodes?[1].id, "2")
        XCTAssertEqual(decodedCanvas.edges?[0].id, "e1")
    }
}
