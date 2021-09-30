import UIKit
import SwiftProtobuf

public enum Response {
    case ping
    case list([Element])
    case error(String)
}

extension Response {
    init(_ bytes: [UInt8]) throws {
        let main = try BinaryDelimited.parse(
            messageType: PB_Main.self,
            from: InputByteStream(bytes))
        self.init(main)
    }

    init(_ main: PB_Main) {
        guard main.commandStatus == .ok else {
            print("command error", main.commandStatus)
            self = .error(main.commandStatus.rawValue.description)
            return
        }
        guard let content = main.content else {
            self = .error("main.content is nil")
            return
        }
        switch main.content {
        case .pingResponse:
            self = .ping
        case .storageListResponse(let response):
            self = .list(.init(response.storageElement.map(Element.init)))
        default:
            self = .error("unsupported api response: \(content)")
        }
    }
}
