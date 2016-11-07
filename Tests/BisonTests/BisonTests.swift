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
            "null": nil,
            "int64": 42
        ]
        
        XCTAssertTrue(
            document.elements[0].value == .double(2.0) &&
            document.elements[1].value == .string("test") &&
//            document.elements[2].value == .document(_) &&
//            document.elements[3].value == .document(_) &&
            document.elements[5].value == .null,
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
