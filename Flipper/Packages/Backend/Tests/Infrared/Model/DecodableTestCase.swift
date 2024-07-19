import XCTest

protocol DecodableTestCase: XCTestCase {
    associatedtype DecodableStruct: Decodable, Equatable

    var testCases: [(DecodableStruct, Data)] { get set }

    func testParseStruct() throws
}

class BaseDecodableTestCase<Struct>: XCTestCase, DecodableTestCase
where Struct: Decodable & Equatable {

    typealias DecodableStruct = Struct
    var testCases: [(DecodableStruct, Data)] = []

    func testParseStruct() throws {
        XCTAssertFalse(testCases.isEmpty)

        try testCases.forEach { (expect, data) in
            let actual = try JSONDecoder().decode(
                DecodableStruct.self,
                from: data)
            XCTAssertEqual(actual, expect)
        }
    }
}
