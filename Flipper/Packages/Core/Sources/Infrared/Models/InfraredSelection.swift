import Infrared
import Foundation

public enum InfraredSelection {
    case signal(InfraredSignal)
    case file(InfraredFile)

    public init(_ selection: Infrared.InfraredSelection) {
        switch selection {
        case .signal(let signal):
            self = .signal(.init(signal))
        case .file(let file):
            self = .file(.init(file))
        }
    }
}
