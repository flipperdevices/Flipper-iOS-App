import Analytics
import Peripheral

import Combine
import Foundation

@MainActor
public class Updater: ObservableObject {
    @Published public var state: State = .busy(.preparing)

    public enum State: Equatable {
        case started
        case canceled
        case busy(Busy)
        case error(Error)

        public enum Busy: Equatable {
            case preparing
            case downloading(progress: Double)
            case uploading(progress: Double)
        }

        public enum Error: Equatable {
            case cantCommunicate
            case cantDownload
            case cantUpload
        }
    }

    public enum Result {
        case success
        case failure
    }

    private var pairedDevice: PairedDevice
    private var rpc: RPC { pairedDevice.session }

    // next step
    let device: Device

    let provider: FirmwareProvider
    let uploader: FirmwareUploader

    private var updateTaskHandle: Task<Void, Swift.Error>?

    public init(pairedDevice: PairedDevice, device: Device) {
        self.pairedDevice = pairedDevice
        self.device = device
        // next step
        self.provider = .init()
        self.uploader = .init(pairedDevice: pairedDevice)
    }

    public func install(_ firmware: Update.Firmware) {
        guard updateTaskHandle == nil else {
            logger.error("update in progress")
            return
        }
        updateTaskHandle = Task {
            do {
                let bytes = try await downloadFirmware(firmware.url)
                let bundle = try await UpdateBundle(unpacking: bytes)

                try await prepareForUpdate()
                try await provideRegion()
                let path = try await uploadFirmware(bundle)
                try await startUpdateProcess(path)
            } catch {
                logger.error("update: \(error)")
            }
            updateTaskHandle = nil
        }
    }

    public func cancel() {
        Task {
            state = .canceled
            device.disconnect()
            try? await Task.sleep(milliseconds: 333)
            device.connect()
        }
    }

    private func prepareForUpdate() async throws {
        state = .busy(.preparing)
        do {
            try await device.showUpdatingFrame()
        } catch {
            state = .error(.cantCommunicate)
            throw error
        }
    }

    private func provideRegion() async throws {
        state = .busy(.preparing)
        do {
            try await device.provideSubGHzRegion()
        } catch let error as Peripheral.Error
            where error == .storage(.internal) {
            state = .error(.cantUpload)
            throw error
        }
    }

    private func downloadFirmware(_ url: URL) async throws -> [UInt8] {
        do {
            state = .busy(.downloading(progress: 0))
            return try await provider.data(from: url) { progress in
                Task { @MainActor in
                    if case .busy(.downloading) = self.state {
                        self.state = .busy(
                            .downloading(progress: progress)
                        )
                    }
                }
            }
        } catch where error is URLError {
            state = .error(.cantDownload)
            throw error
        }
    }

    private func uploadFirmware(
        _ bundle: UpdateBundle
    ) async throws -> Peripheral.Path {
        do {
            state = .busy(.preparing)
            return try await uploader.upload(bundle) { progress in
                Task { @MainActor in
                    if case .busy = self.state {
                        self.state = .busy(
                            .uploading(progress: progress)
                        )
                    }
                }
            }
        } catch let error as Peripheral.Error
            where error == .storage(.internal)
        {
            state = .error(.cantUpload)
            throw error
        }
    }

    private func startUpdateProcess(
        _ directory: Peripheral.Path
    ) async throws {
        state = .busy(.preparing)
        try await device.startUpdateProcess(from: directory)
        state = .started
    }
}
