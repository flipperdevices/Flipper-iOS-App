import SwiftUI

public struct LockScreenBanner: View {
    let state: Update.State
    let version: Update.Version

    public init(state: Update.State, version: Update.Version) {
        self.state = state
        self.version = version
    }

    public var body: some View {
        switch state {
        case .progress(let progress):
            Progress(state: progress, version: version)
        case .result(let result):
            Result(state: result, version: version)
        }
    }

    struct Progress: View {
        let state: Update.State.Progress
        let version: Update.Version

        var color: Color {
            switch state {
            case .downloading: return .sGreenUpdate
            case .preparing, .uploading: return .a2
            }
        }

        var body: some View {
            VStack(spacing: 8) {
                UpdateProgressVersion(version)
                    .font(.system(size: 18, weight: .medium))
                UpdateProgressBar(state: state)
                    .padding(.horizontal, 24)
                UpdateProgressDescription(state: state)
            }
        }
    }

    struct Result: View {
        let state: Update.State.Result
        let version: Update.Version

        var body: some View {
            switch state {
            case .started: Started()
            case .canceled: Canceled()
            case .succeeded: Succeeded()
            case .failed: Failed()
            }
        }

        struct Started: View {
            var body: some View {
                VStack(spacing: 8) {
                    Image("UpdateStartedActivity")
                    Text(
                        "Flipper is updating in offline mode. " +
                        "Check the device \nscreen for info and " +
                        "wait for reconnect."
                    )
                    .font(.system(size: 12, weight: .medium))
                    .lineLimit(2, reservesSpace: true)
                    .multilineTextAlignment(.center)
                    .foregroundColor(.black30)
                }
            }
        }

        struct Canceled: View {
            var body: some View {
                VStack(spacing: 8) {
                    Image("UpdateCanceledActivity")
                    Text("Update Aborted")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(.sRed)
                }
            }
        }

        struct Succeeded: View {
            var body: some View {
                VStack(spacing: 8) {
                    Image("UpdateSuccessActivity")
                    Text("Update Successful")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(.sGreenUpdate)
                }
            }
        }

        struct Failed: View {
            var body: some View {
                VStack(spacing: 8) {
                    Image("UpdateFailedActivity")
                    Text("Update Failed")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(.sRed)
                }
            }
        }
    }
}
