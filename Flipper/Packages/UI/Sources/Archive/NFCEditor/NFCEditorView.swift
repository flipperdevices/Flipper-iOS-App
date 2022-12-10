import Core
import SwiftUI

struct NFCEditorView: View {
    @EnvironmentObject var archiveService: ArchiveService
    @StateObject var alertController: AlertController = .init()
    @StateObject var hexKeyboardController: HexKeyboardController = .init()
    @Environment(\.dismiss) private var dismiss

    @Binding var item: ArchiveItem

    var mifareType: String {
        guard let typeProperty = item.props.first(
            where: { $0.key == "Mifare Classic type" }
        ) else {
            return "??"
        }
        return typeProperty.value
    }

    @State private var uid: [UInt8] = []
    @State private var atqa: [UInt8] = []
    @State private var sak: [UInt8] = []
    @State private var hasBCC = false

    @State private var bytes: [UInt8?] = []
    @State private var showSaveAs = false
    @State private var showSaveChanges = false
    @State private var error: String?

    var body: some View {
        NavigationView {
            ZStack {
                VStack(spacing: 0) {
                    Header(
                        title: "Edit Dump",
                        description: item.name.value,
                        onCancel: {
                            cancel()
                        },
                        onSave: {
                            save()
                        },
                        onSaveAs: {
                            saveAs()
                        }
                    )
                    .simultaneousGesture(TapGesture().onEnded {
                        hexKeyboardController.onKey(.ok)
                    })

                    ScrollView {
                        VStack(spacing: 24) {
                            NFCCard(
                                mifareType: mifareType,
                                uid: uid,
                                atqa: atqa,
                                sak: sak)

                            HexEditor(
                                bytes: $bytes,
                                width: UIScreen.main.bounds.width - 28
                            )
                        }
                        .padding(14)
                    }

                    NavigationLink("", isActive: $showSaveAs) {
                        SaveAsView(item: $item)
                            .onDisappear {
                                dismiss()
                            }
                    }

                    if !hexKeyboardController.isHidden {
                        HexKeyboard(
                            onButton: { hexKeyboardController.onKey(.hex($0)) },
                            onBack: { hexKeyboardController.onKey(.back) },
                            onOK: { hexKeyboardController.onKey(.ok) }
                        )
                        .transition(.move(edge: .bottom))
                    }
                }
                .navigationBarHidden(true)
                .customAlert(isPresented: $showSaveChanges) {
                    SaveChangesAlert(
                        save: save,
                        saveAs: saveAs,
                        dismiss: dismiss
                    )
                }
                .environmentObject(alertController)
                .environmentObject(hexKeyboardController)

                if alertController.isPresented {
                    alertController.alert
                }
            }
        }
        .alert(item: $error) { error in
            Alert(title: Text(error))
        }
        .task {
            self.uid = item.uid
            self.atqa = item.atqa
            self.sak = item.sak
            self.bytes = item.nfcBlocks
            self.hasBCC = item.hasBCC
        }
        .onChange(of: bytes) { _ in
            updateUID()
        }
    }

    func updateUID() {
        var index = uid.count

        // UID should be 4 or 7 bytes, Sector 0 should be 64 bytes
        guard (index == 4 || index == 7), bytes.count >= 64 else { return }

        // ATQA byte order depends on version
        guard let version = item.version else { return }

        // MARK: UID

        let newUID = bytes
            .prefix(upTo: index)
            .map { $0 ?? 0 }

        if uid != newUID {
            uid = .init(newUID)
            if hasBCC {
                // NOTE: calculate BCC
                bytes[index] = newUID.bcc
            }
        }

        if hasBCC {
            index += 1
        }

        // MARK: SAK

        sak = [bytes[index] ?? 0]
        index += 1

        // MARK: ATQA

        let newATQA = bytes
            .suffix(from: index)
            .prefix(2)
            .map { $0 ?? 0 }

        atqa = version >= 3
            ? newATQA.reversed()
            : newATQA
    }

    func cancel() {
        if item.nfcBlocks == bytes {
            dismiss()
        } else {
            showSaveChanges = true
        }
    }

    func save() {
        item.uid = uid
        item.sak = sak
        item.atqa = atqa
        item.nfcBlocks = bytes
        Task {
            do {
                try await archiveService.save(item, as: item)
            } catch {
                showError(error)
            }
        }
        dismiss()
    }

    func saveAs() {
        item.uid = uid
        item.sak = sak
        item.atqa = atqa
        item.nfcBlocks = bytes
        showSaveAs = true
    }

    func showError(_ error: Swift.Error) {
        self.error = String(describing: error)
    }
}

private extension ArchiveItem {
    var props: [Property] {
        shadowCopy.isEmpty
            ? self.properties
            : self.shadowCopy
    }

    var version: Int? {
        guard let version = props.first(where: { $0.key == "Version" }) else {
            return nil
        }
        return Int(version.value)
    }

    var hasBCC: Bool {
        guard let block0 = props.first(where: { $0.key == "Block 0" }) else {
            return false
        }
        let uid = uid
        let bytes = [UInt8](hexString: block0.value)
        guard !uid.isEmpty, bytes.count > uid.count else {
            return false
        }
        return bytes[uid.count] == uid.bcc
    }

    var uid: [UInt8] {
        get {
            guard let property = props.first(where: { $0.key == "UID" }) else {
                return []
            }
            return .init(hexString: property.value)
        }
        set {
            shadowCopy = props
            if let index = shadowCopy.index(of: "UID") {
                shadowCopy[index].value = newValue.hexString
            }
        }
    }

    var atqa: [UInt8] {
        get {
            guard let property = props.first(where: { $0.key == "ATQA" }) else {
                return []
            }
            return .init(hexString: property.value)
        }
        set {
            shadowCopy = props
            if let index = shadowCopy.index(of: "ATQA") {
                shadowCopy[index].value = newValue.hexString
            }
        }
    }

    var sak: [UInt8] {
        get {
            guard let property = props.first(where: { $0.key == "SAK" }) else {
                return []
            }
            return .init(hexString: property.value)
        }
        set {
            shadowCopy = props
            if let index = shadowCopy.index(of: "SAK") {
                shadowCopy[index].value = newValue.hexString
            }
        }
    }

    var nfcBlocks: [UInt8?] {
        get {
            let properties = shadowCopy.isEmpty
                ? self.properties
                : self.shadowCopy
            let blocks = properties.filter { $0.key.starts(with: "Block ") }
            guard blocks.count == 64 || blocks.count == 256 else {
                return []
            }
            var result = [UInt8?]()
            for block in blocks {
                let bytes = block
                    .value
                    .split(separator: " ")
                    .map { UInt8($0, radix: 16) }
                result.append(contentsOf: bytes)
            }
            return result
        }
        set {
            guard newValue.count == 1024 || newValue.count == 4096 else {
                return
            }
            if shadowCopy.isEmpty {
                shadowCopy = properties
            }
            for block in 0..<newValue.count / 16 {
                var startIndex: Int { block * 16 }
                var endIndex: Int { startIndex + 16 }
                let bytes: [String] = newValue[startIndex..<endIndex].map {
                    guard let byte = $0 else {
                        return "??"
                    }
                    return byte < 16
                        ? "0" + String(byte, radix: 16).uppercased()
                        : String(byte, radix: 16).uppercased()
                }
                if let index = shadowCopy.index(of: "Block \(block)") {
                    shadowCopy[index].value = bytes.joined(separator: " ")
                }
            }
        }
    }
}

private extension Array where Element == ArchiveItem.Property {
    func index(of key: String) -> Int? {
        self.firstIndex { $0.key == key }
    }
}

private extension Array where Element == UInt8 {
    var hexString: String {
        self
            .map {
                String(format: "%02X", $0)
            }
            .joined(separator: " ")
            .uppercased()
    }

    init(hexString: String) {
        self = hexString
            .split(separator: " ")
            .map { UInt8($0, radix: 16) ?? 0 }
    }
}

private extension Array where Element == UInt8 {
    var bcc: UInt8? {
        guard count == 4 || count == 7 else {
            return nil
        }
        return reduce(0, ^)
    }
}

private extension ArraySlice where Element == UInt8 {
    var bcc: UInt8? {
        [UInt8](self).bcc
    }
}
