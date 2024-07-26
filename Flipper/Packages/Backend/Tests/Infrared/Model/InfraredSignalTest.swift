import XCTest
@testable import Infrared

final class InfraredSignalTest: BaseDecodableTestCase<InfraredSignal> {

    override func setUp() {
        super.setUp()
        testCases = [
            (.mockRaw, .mockRaw),
            (.mockParsed, .mockParsed),
            (.mockWrongType, .mockWrongType)
        ]
    }
}

fileprivate extension InfraredSignal {
    static let mockRaw = InfraredSignal(
        response: .init(
            model: .init(
                id: 0,
                ifrFileId: 0,
                brandId: 0,
                categoryId: 0,
                name: "name",
                hash: "hash",
                data: .raw(
                    .init(
                        frequency: "38200",
                        dutyCycle: "0.330000",
                        data: "8942")
                )
            ),
            message: "message",
            categoryName: "categoryName",
            data: .unknown
        )
    )

    static let mockParsed = InfraredSignal(
        response: .init(
            model: .init(
                id: 0,
                ifrFileId: 0,
                brandId: 0,
                categoryId: 0,
                name: "name",
                hash: "hash",
                data: .parsed(
                    .init(
                        protocol: "38200",
                        address: "0.330000",
                        command: "8942")
                )
            ),
            message: "message",
            categoryName: "categoryName",
            data: .unknown
        )
    )

    static let mockWrongType = InfraredSignal(
        response: .init(
            model: .init(
                id: 0,
                ifrFileId: 0,
                brandId: 0,
                categoryId: 0,
                name: "name",
                hash: "hash",
                data: .unknown
            ),
            message: "message",
            categoryName: "categoryName",
            data: .unknown
        )
    )
}

fileprivate extension Data {
    static let mockRaw =
    """
    {
        "signal_response": {
            "signal_model": {
                "id": 0,
                "ifr_file_id": 0,
                "brand_id": 0,
                "category_id": 0,
                "name": "name",
                "type": "raw",
                "frequency": "38200",
                "duty_cycle": "0.330000",
                "data": "8942",
                "hash": "hash"
            },
            "message": "message",
            "category_name": "categoryName",
            "data": {
                "type": "hakuna-matata",
            }
        }
    }
    """.data(using: .utf8)!

    static let mockParsed =
    """
    {
        "signal_response": {
            "signal_model": {
                "id": 0,
                "ifr_file_id": 0,
                "brand_id": 0,
                "category_id": 0,
                "name": "name",
                "type": "parsed",
                "protocol": "38200",
                "address": "0.330000",
                "command": "8942",
                "hash": "hash"
            },
            "message": "message",
            "category_name": "categoryName",
            "data": {
                "type": "hakuna-matata",
            }
        }
    }
    """.data(using: .utf8)!

    static let mockWrongType =
    """
    {
        "signal_response": {
            "signal_model": {
                "id": 0,
                "ifr_file_id": 0,
                "brand_id": 0,
                "category_id": 0,
                "name": "name",
                "type": "test",
                "protocol": "38200",
                "address": "0.330000",
                "command": "8942",
                "hash": "hash"
            },
            "message": "message",
            "category_name": "categoryName",
            "data": {
                "type": "hakuna-matata",
            }
        }
    }
    """.data(using: .utf8)!
}
