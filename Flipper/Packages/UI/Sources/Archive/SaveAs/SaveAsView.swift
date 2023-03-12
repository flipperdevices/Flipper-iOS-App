import Core
import SwiftUI

struct SaveAsView: View {
    @EnvironmentObject var archive: ArchiveModel
    @StateObject var alertController: AlertController = .init()
    @Environment(\.dismiss) private var dismiss

    @Binding var item: ArchiveItem
    @State private var error: String?

    var body: some View {
        ZStack {
            VStack(alignment: .leading, spacing: 0) {
                ZStack {
                    HStack {
                        BackButton {
                            dismiss()
                        }
                        Spacer()
                    }

                    HStack {
                        Spacer()
                        Text("Save Dump as..")
                            .font(.system(size: 18, weight: .bold))
                        Spacer()
                    }

                    HStack {
                        Spacer()
                        Button {
                            save()
                        } label: {
                            Text("Save")
                                .foregroundColor(.primary)
                                .font(.system(size: 14, weight: .medium))
                        }
                        .frame(width: 66)
                    }
                }
                .padding(.horizontal, 11)
                .padding(.top, 17)
                .padding(.bottom, 6)

                ScrollView {
                    VStack(alignment: .leading, spacing: 0) {
                        CardView(
                            item: $item,
                            isEditing: .init(get: { true }, set: { _ in }),
                            kind: .existing
                        )
                        .padding(.top, 14)
                        .padding(.horizontal, 24)

                        Spacer()
                    }
                }
            }

            if alertController.isPresented {
                alertController.alert
            }
        }
        .navigationBarHidden(true)
        .alert(item: $error) { error in
            Alert(title: Text(error))
        }
        .background(Color.background)
        .edgesIgnoringSafeArea(.bottom)
    }

    func save() {
        Task {
            do {
                try await archive.add(item)
                dismiss()
            } catch {
                showError(error)
            }
        }
    }

    func showError(_ error: Swift.Error) {
        self.error = String(describing: error)
    }
}
