import Infrared
import Foundation

public enum InfraredSelection {
    case signal(InfraredSignal)
    case file(InfraredFile)

    public init(_ selection: Infrared.InfraredSelection) throws {
        if let signal = selection.signal {
            self = .signal(.init(signal))
        } else if let file = selection.file {
            self = .file(.init(file))
        } else {
            throw InfraredError.invalidSignalResponse
        }
    }
}
