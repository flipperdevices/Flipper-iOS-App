import XCTest

@testable import Core

class ReaderLogTests: XCTestCase {
    var log: String { ReaderLog.testLog }

    func testReaderLog() throws {
        let readerLog = try ReaderLog(log)
        XCTAssertEqual(readerLog.lines.count, 20)
    }

    func testReaderLogLine() throws {
        let readerLog = try ReaderLog(log)
        guard readerLog.lines.count == 20 else {
            return
        }
        let line = readerLog.lines[2]

        XCTAssertEqual(line.number, 3)
        XCTAssertEqual(line.keyType, .a)
        XCTAssertEqual(line.sector, 2)
        XCTAssertEqual(line.readerData.uid, 0x2a234f80)
        XCTAssertEqual(line.readerData.nt0, 0x2b6dad5a)
        XCTAssertEqual(line.readerData.nr0, 0x709043c8)
        XCTAssertEqual(line.readerData.ar0, 0x282548af)
        XCTAssertEqual(line.readerData.nt1, 0x0231ea00)
        XCTAssertEqual(line.readerData.nr1, 0xf4a385ae)
        XCTAssertEqual(line.readerData.ar1, 0x9846ae5d)
    }
}

extension ReaderLog {
    static var testLog: String {
        """
        Sec 2 key A cuid 2a234f80 nt0 55721809 nr0 ce9985f6 ar0 772f55be nt1 a27173f2 nr1 e386b505 ar1 5fa65203
        Sec 2 key A cuid 2a234f80 nt0 ea47d2a6 nr0 a94ae154 ar0 38b015ae nt1 dd75bf17 nr1 380601d5 ar1 e405a440
        Sec 2 key A cuid 2a234f80 nt0 2b6dad5a nr0 709043c8 ar0 282548af nt1 0231ea00 nr1 f4a385ae ar1 9846ae5d
        """
    }
}
