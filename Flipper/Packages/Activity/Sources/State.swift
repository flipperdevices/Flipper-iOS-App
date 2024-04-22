// Copied & Adapted from Core.Update & Core.UpdateModel

public enum Update {
    public enum State: Equatable, Codable, Hashable {
        case progress(Progress)
        case result(Result)

        public enum Progress: Equatable, Codable, Hashable {
            case preparing
            case downloading(Double)
            case uploading(Double)
        }

        public enum Result: Equatable, Codable, Hashable {
            case started
            case canceled
            case succeeded
            case failed
        }
    }

    public struct Version: Equatable, Codable {
        public let name: String
        public let channel: Channel

        public init(name: String, channel: Channel) {
            self.name = name
            self.channel = channel
        }
    }

    public enum Channel: String, Equatable, Codable {
        case development
        case candidate
        case release
        case custom
    }
}
