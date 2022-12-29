import Inject
import Analytics
import Peripheral

import Foundation
import Logging

//extension Update {
    public struct VersionUpdateModel {
        public var state: State = .busy(.connecting)

        public var selectedChannel: Update.Channel {
            didSet {
                UserDefaultsStorage
                    .shared
                    .updateChannel = selectedChannel.rawValue
            }
        }

        public var manifest: Update.Manifest?

        public var installed: Update.Version?
        public var available: Update.Version?

        public var intent: Update.Intent?

        public init(selectedChannel: Update.Channel) {
            self.selectedChannel = selectedChannel
        }

        public init() {
            let selectedChannel = UserDefaultsStorage.shared.updateChannel
            self.selectedChannel = .init(rawValue: selectedChannel)
        }

        public enum State: Equatable {
            case busy(Busy)
            case ready(Ready)
            case error(Error)

            public enum Busy: Equatable {
                case connecting
                case loadingManifest
                case updateInProgress(Update.Intent)
            }

            public enum Ready: Equatable {
                case noUpdates
                case versionUpdate
                case channelUpdate
            }

            public enum Error: Equatable {
                case noCard
                case noDevice
                case noInternet
                case cantConnect
            }
        }
    }
//}
