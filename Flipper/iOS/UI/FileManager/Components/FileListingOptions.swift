import SwiftUI

extension FileManagerView.FileManagerListing {
    struct FileListingOptions: View {
        @Binding var isPresented: Bool
        @Binding var settings: FileManagerSettings

        let upload: () -> Void

        var body: some View {
            HStack {
                Spacer()
                Card {
                    VStack(alignment: .leading, spacing: 0) {
                        Option(title: "Upload", image: "Share") {
                            isPresented = false
                            upload()
                        }

                        Divider()

                        Option(title: "List", image: "List") {
                            isPresented = false
                            settings.displayType = .list
                        }

                        Option(title: "Grid", image: "Grid") {
                            isPresented = false
                            settings.displayType = .grid
                        }

                        Divider()

                        ShowHiddenFilesOption(
                            isPresented: $isPresented,
                            settings: $settings
                        )
                    }
                }
                .frame(width: 200)
            }
            .padding(.horizontal, 14)
            .offset(y: 40)
        }
    }
}

fileprivate extension FileManagerView.FileManagerListing.FileListingOptions {
    struct Option: View {
        let title: String
        let image: String
        let onTap: () -> Void

        var body: some View {
            Button(action: onTap) {
                HStack(spacing: 8) {
                    Image(image)
                        .resizable()
                        .renderingMode(.template)
                        .frame(width: 24, height: 24)
                        .foregroundColor(.primary)
                    Text(title)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.primary)
                    Spacer()
                }
            }
            .padding(12)
        }
    }

    struct ShowHiddenFilesOption: View {
        @Binding var isPresented: Bool
        @Binding var settings: FileManagerSettings

        var body: some View {
            Button(action: {
                settings.isHiddenFilesShow.toggle()
                isPresented = false
            }, label: {
                HStack(spacing: 8) {
                    ZStack {
                        Circle()
                            .stroke(Color.black30, lineWidth: 2)

                        if settings.isHiddenFilesShow {
                            Circle()
                                .fill(Color.a1)
                                .padding(4)
                        }
                    }
                    .frame(width: 20, height: 20)
                    .padding(2)

                    Text("Show Hidden Files")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.primary)
                    Spacer()
                }
            })
            .padding(12)
        }
    }
}
