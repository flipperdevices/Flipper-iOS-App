import XCTest

protocol EncodableTestCase: XCTestCase {
    associatedtype EncodableStruct: Encodable, Equatable

    var testCases: [(Data, EncodableStruct)] { get set }

    func testParseStruct() throws
}

class BaseEncodableTestCase<Struct>: XCTestCase, EncodableTestCase
where Struct: Encodable & Equatable {

    typealias EncodableStruct = Struct
    var testCases: [(Data, EncodableStruct)] = []

    func testParseStruct() throws {
        XCTAssertFalse(testCases.isEmpty)

        try testCases.forEach { (expectedData, expectedStruct) in
            let actualData = try JSONEncoder().encode(expectedStruct)

            let expectedJSON = try JSONSerialization.jsonObject(
                with: expectedData,
                options: .allowFragments)
            let actualJSON = try JSONSerialization.jsonObject(
                with: actualData,
                options: .allowFragments)

            let expectedSortedData = try JSONSerialization.data(
                withJSONObject: expectedJSON,
                options: [.sortedKeys])
            let actualSortedData = try JSONSerialization.data(
                withJSONObject: actualJSON,
                options: [.sortedKeys])

            XCTAssertEqual(expectedSortedData, actualSortedData)
        }
    }
}
