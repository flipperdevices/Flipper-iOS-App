public enum Error: Equatable, Swift.Error {
    case common(CommonError)
    case storage(StorageError)
    case application(ApplicationError)
    case unsupported(Int)

    public enum CommonError: Equatable, Swift.Error {
        case unknown
        case decode
        case notImplemented
        case busy
        case continuousCommandInterrupted
        case invalidParameters
    }

    public enum StorageError: Equatable, Swift.Error {
        case notReady
        case exists
        case doesNotExist
        case invalidParameter
        case denied
        case invalidName
        case `internal`
        case notImplemented
        case alreadyOpen
        case notEmpty
    }

    public enum ApplicationError: Equatable, Swift.Error {
        case cantStart
        case systemLocked
    }
}

// MARK: Initializer

extension Error {
    // swiftlint:disable cyclomatic_complexity
    init(_ source: PB_CommandStatus) {

        switch source {
        case .error:
            self = .common(.busy)
        case .errorDecode:
            self = .common(.decode)
        case .errorNotImplemented:
            self = .common(.notImplemented)
        case .errorBusy:
            self = .common(.busy)
        case .errorContinuousCommandInterrupted:
            self = .common(.continuousCommandInterrupted)
        case .errorInvalidParameters:
            self = .common(.invalidParameters)

        case .errorStorageNotReady:
            self = .storage(.notReady)
        case .errorStorageExist:
            self = .storage(.exists)
        case .errorStorageNotExist:
            self = .storage(.doesNotExist)
        case .errorStorageInvalidParameter:
            self = .storage(.invalidParameter)
        case .errorStorageDenied:
            self = .storage(.denied)
        case .errorStorageInvalidName:
            self = .storage(.invalidName)
        case .errorStorageInternal:
            self = .storage(.internal)
        case .errorStorageNotImplemented:
            self = .storage(.notImplemented)
        case .errorStorageAlreadyOpen:
            self = .storage(.alreadyOpen)
        case .errorStorageDirNotEmpty:
            self = .storage(.notEmpty)

        case .errorAppCantStart:
            self = .application(.cantStart)
        case .errorAppSystemLocked:
            self = .application(.systemLocked)

        case .ok, .UNRECOGNIZED:
            self = .unsupported(source.rawValue)
        }
    }
}

// MARK: CustomStringConvertible

extension Error: CustomStringConvertible {
    public var description: String {
        switch self {
        case .common(let commonError):
            return "CommonError: \(commonError)"
        case .storage(let storageError):
            return "StorageError: \(storageError)"
        case .application(let applicationError):
            return "ApplicationError: \(applicationError)"
        case .unsupported(let code):
            return "Unsupported error code: \(code)"
        }
    }
}

extension Error.CommonError: CustomStringConvertible {
    public var description: String {
        switch self {
        case .unknown:
            return "Unknown error"
        case .decode:
            return "Can't decode command"
        case .notImplemented:
            return "Command is not implemented"
        case .busy:
            return "Busy - somebody took global lock"
        case .continuousCommandInterrupted:
            return "Interrupted - did not receive hasNext = false"
        case .invalidParameters:
            return "Invalid parameters"
        }
    }
}

extension Error.StorageError: CustomStringConvertible {
    public var description: String {
        switch self {
        case .notReady:
            return "Filesystem is not ready"
        case .exists:
            return "File/Directory already exists"
        case .doesNotExist:
            return "File/Directory does not exist"
        case .invalidParameter:
            return "Invalid parameter"
        case .denied:
            return "Access denied"
        case .invalidName:
            return "Invalid name/path"
        case .internal:
            return "Internal error"
        case .notImplemented:
            return "Storage function is not implemented"
        case .alreadyOpen:
            return "File/Directory is already open"
        case .notEmpty:
            return "Directory is not empty"
        }
    }
}

extension Error.ApplicationError: CustomStringConvertible {
    public var description: String {
        switch self {
        case .cantStart:
            return "Can't start app - internal error"
        case .systemLocked:
            return "System locked - another app is running"
        }
    }
}
