import XCTest
@testable import Bison

class BisonTests : XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testDocumentLiteral() {
        
        let document: Document = [
            "double": 2.0,
            "string": "test",
            "document": [
                "level": 1,
                "document": ["level": 2]
            ],
            "array": [1, 2, 3],
            "bool": true,
            "int64": 42
        ]
        
        XCTAssertTrue(
            document["double"]    == 2.0
            && document["double"] == .double(2.0)
            && document["string"] == "test"
            && document["string"] == .string("test")
            && document["array"]  == [1, 2, 3]
            && document["array"]  == .array([1, 2, 3])
            && document["bool"]   == true
            && document["bool"]   == .bool(true)
            && document["int64"]  == 42
            && document["int64"]  == .int64(42)
            && document[document: "document"]!["level"] == 1
            && document[document: "document"]!["level"] == .int64(1)
            && document[document: "document"]![document: "document"]! == ["level": 2]
            && document[document: "document"]!["document"] == .document(["level": 2])
            && document[document: "document"]![document: "document"]!["level"] == 2
            && document[document: "document"]![document: "document"]!["level"] == .int64(2)
            && document[array: "array"]!    == [1, 2, 3]
            && document[array: "array"]![0] == 1
            && document[array: "array"]![0] == .int64(1)
            && document[array: "array"]![1] == 2
            && document[array: "array"]![1] == .int64(2)
            && document[array: "array"]![2] == 3
            && document[array: "array"]![2] == .int64(3),
            "Document dictionary literal validation failed")
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }

    static var allTests : [(String, (BisonTests) -> () throws -> Void)] {
        
        return [
            ("testDocumentLiteral", testDocumentLiteral),
            ("testExample", testExample),
        ]
    }
}
