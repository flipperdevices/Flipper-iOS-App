import Inject
import Analytics
import Peripheral

import Foundation
import Combine
import Logging

//extension Update {
    public struct UpdateModel {
        public var state: State = .update(.preparing)

        public var inProgress: Update.Intent?
        public var result: SafeSubject<Result> = .init()

        public enum State: Equatable {
            case update(Update)
            case error(Error)

            public enum Update: Equatable {
                case preparing
                case downloading(progress: Double)
                case uploading(progress: Double)
                case started
                case canceling
            }

            public enum Error: Equatable {
                case cantConnect
                case noInternet
                case noDevice
                case noCard
                case storageError
                case outdatedApp
                case failedDownloading
                case failedPreparing
                case failedUploading
                case canceled
            }
        }

        public enum Result {
            case success
            case failure
        }
    }
//}
