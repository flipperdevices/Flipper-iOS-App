import XCTest

func XCTAssertEqual(
    _ lhs: [Double],
    _ rhs: [Double],
    accuracy: Double,
    file: StaticString = #filePath,
    line: UInt = #line
) {
    func fail() {
        XCTFail(
            "(\"\(lhs)\") is not equal to (\"\(rhs)\")",
            file: file,
            line: line
        )
    }
    guard lhs.count == rhs.count else {
        fail()
        return
    }
    for i in 0..<lhs.count {
        guard lhs[i].distance(to: rhs[i]).magnitude <= accuracy else {
            fail()
            return
        }
    }
}
