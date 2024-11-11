import Core
import SwiftUI

extension InfraredView {
    struct InfraredPagesLayout: View {
        @Environment(\.dismiss) private var dismiss
        @Environment(\.path) private var path
        @Environment(\.notifications) private var notifications

        @EnvironmentObject private var emulate: Emulate
        @EnvironmentObject private var device: Device
        @EnvironmentObject private var archive: ArchiveModel
        @EnvironmentObject private var infraredModel: InfraredModel

        @State private var layout: InfraredLayout?
        @State private var content: InfraredKeyContent?

        @State private var isFlipperBusyAlertPresented: Bool = false
        @State private var showRemoteControl = false
        @State private var remoteFoundAlertPresented: Bool = false

        @State private var viewState: ViewState = .loadLayoyt
        @State private var layoutState: InfraredLayoutState = .default

        private var canSaveLayout: Bool {
            if case .display(_, let state) = viewState {
                return state == .default
            } else {
                return false
            }
        }

        private var keyName: Substring {
            file.name
                .replacingOccurrences(of: " ", with: "_")
                .replacingOccurrences(of: "\\", with: "_")
                .replacingOccurrences(of: "/", with: "_")
                .replacingOccurrences(of: ".", with: "_")
                .prefix(21)
        }

        private var archiveItem: ArchiveItem? {
            guard let content else { return nil }

            return .init(
                name: .init(keyName),
                kind: .infrared,
                properties: content.properties,
                shadowCopy: [],
                layout: layout?.data
            )
        }

        let file: InfraredFile

        enum ViewState: Equatable {
            case loadLayoyt
            case flipperNotConnected
            case display(InfraredLayout, InfraredLayoutState)
            case syncing(InfraredLayout, Double)
            case error(InfraredModel.Error.Network)
        }

        var body: some View {
            VStack(spacing: 0) {
                switch viewState {
                case .loadLayoyt:
                    InfraredLayoutPagesView(
                        layout: InfraredLayout.progressMock
                    )
                    .environment(\.layoutState, .syncing)
                case .error(let error):
                    InfraredNetworkError(error: error, action: retry)
                case .flipperNotConnected:
                    InfraredFlipperNotConnectedError()
                case .syncing(let layout, _):
                    InfraredLayoutPagesView(layout: layout)
                        .environment(\.layoutState, .syncing)
                case .display(let layout, let state):
                    InfraredLayoutPagesView(layout: layout)
                        .environment(\.layoutState, state)
                        .environment(\.emulateAction, onStartEmulate)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.background)
            .navigationBarBackButtonHidden(true)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                LeadingToolbarItems {
                    BackButton {
                        dismiss()
                    }
                }
                PrincipalToolbarItems {
                    let description = switch viewState {
                    case .loadLayoyt:
                        "Downloading layout"
                    case .syncing(_, let progress):
                        "Uploading to Flipper: \(Int(progress * 100))%"
                    default:
                        "Remote"
                    }
                    Title(file.name, description: description)
                }
                TrailingToolbarItems {
                    HStack {
                        SaveButton {
                            guard let item = archiveItem else { return }
                            path.append(Destination.save(file, item))
                        }
                        .disabled(!canSaveLayout)

                        CloseButton {
                            path.clear()
                        }
                    }
                }
            }
            .notification(
                isPresented: notifications.infraredLibrary.showRemoteFound
            ) {
                RemoteFoundBanner()
            }
            .alert(isPresented: $isFlipperBusyAlertPresented) {
                FlipperIsBusyAlert(
                    isPresented: $isFlipperBusyAlertPresented,
                    goToRemote: { showRemoteControl = true }
                )
            }
            .sheet(isPresented: $showRemoteControl) {
                RemoteControlView()
                    .environmentObject(device)
            }
            .task {
                if device.status != .connected {
                    viewState = .flipperNotConnected
                    return
                }
                if layout != nil, content != nil {
                    return
                }
                await processLoadFile()
            }
            .onChange(of: device.status) { status in
                if status != .connected {
                    viewState = .flipperNotConnected
                } else {
                    retry()
                }
            }
            .onChange(of: emulate.state) { state in
                guard let layout else { return }

                if state == .closed {
                    viewState = .display(layout, .default)
                }
                if state == .locked {
                    viewState = .display(layout, .default)
                    self.isFlipperBusyAlertPresented = true
                }
                if state == .staring || state == .started || state == .closed {
                    feedback(style: .soft)
                }
            }
        }

        private func processLoadFile() async {
            notifications.infraredLibrary.showRemoteFound = true
            viewState = .loadLayoyt
            do {
                let layout = try await infraredModel.loadLayout(file)
                let fileContent = try await infraredModel.loadContent(file)
                self.layout = layout
                self.content = fileContent
                viewState = .syncing(layout, 0)

                try await infraredModel
                    .sendTempContent(fileContent.properties.content) {
                        viewState = .syncing(layout, $0 / 2)
                    }

                try await infraredModel.sendTempLayout(layout) {
                    viewState = .syncing(layout, $0 / 2 + 0.5)
                }

                viewState = .display(layout, .default)
            } catch let error as InfraredModel.Error.Network {
                viewState = .error(error)
            } catch {}
        }

        private func onStartEmulate(_ keyID: InfraredKeyID) {
            guard
                let layout, let archiveItem,
                let index = archiveItem.infraredSignals.firstIndex(keyId: keyID)
            else { return }

            viewState = .display(layout, .emulating)
            emulate.startEmulate(.tempIfr, config: .byIndex(index))
        }

        private func retry() {
            Task {
                notifications.infraredLibrary.showRemoteFound = false
                await processLoadFile()
            }
        }
    }
}
