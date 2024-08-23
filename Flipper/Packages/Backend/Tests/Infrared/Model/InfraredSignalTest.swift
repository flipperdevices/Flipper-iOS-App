import XCTest
@testable import Infrared

final class InfraredSignalTest: BaseDecodableTestCase<InfraredSelection> {

    override func setUp() {
        super.setUp()
        testCases = [
            (.mockResponseRaw, .mockResponseRaw),
            (.mockResponseParsed, .mockResponseParsed),
            (.mockIfrModelResponseRaw, .mockIfrModelResponseRaw)
        ]
    }
}

fileprivate extension InfraredSelection {
    static let mockResponseRaw = InfraredSelection.signal(
        .init(
            message: "message",
            categoryName: "categoryName",
            data: .unknown,
            model: .init(
                id: 0,
                remote: .raw(
                    .init(
                        frequency: "38200",
                        dutyCycle: "0.330000",
                        data: "8942",
                        name: "name")
                )
            )
        )
    )

    static let mockResponseParsed = InfraredSelection.signal(
        .init(
            message: "message",
            categoryName: "categoryName",
            data: .unknown,
            model: .init(
                id: 0,
                remote: .parsed(
                    .init(
                        protocol: "38200",
                        address: "0.330000",
                        command: "8942",
                        name: "name")
                )
            )
        )
    )

    static let mockIfrModelResponseRaw = InfraredSelection.file(
        .init(
            id: 0,
            brandId: 0,
            fileName: "filename",
            folderName: "Test"
        )
    )
}

fileprivate extension Data {
    static let mockResponseRaw = Data(
            """
            {
                "signal_response": {
                    "signal_model": {
                        "id": 0,
                        "remote": {
                           "name": "name",
                           "type": "raw",
                           "frequency": "38200",
                           "duty_cycle": "0.330000",
                           "data": "8942"
                        },
                    },
                    "message": "message",
                    "category_name": "categoryName",
                    "data": {
                        "type": "hakuna-matata",
                    }
                }
            }
            """.utf8
    )

    static let mockResponseParsed = Data(
        """
        {
            "signal_response": {
                "signal_model": {
                    "id": 0,
                    "remote": {
                        "name": "name",
                        "type": "parsed",
                        "protocol": "38200",
                        "address": "0.330000",
                        "command": "8942"
                    },
                },
                "message": "message",
                "category_name": "categoryName",
                "data": {
                    "type": "hakuna-matata",
                }
            }
        }
        """.utf8
    )

    static let mockIfrModelResponseRaw = Data(
        """
        {
            "ifr_file_model": {
                "id": 0,
                "brand_id": 0,
                "file_name": "filename",
                "folder_name": "Test"
            }
        }
        """.utf8
    )
}
