import SwiftUI
import Peripheral

extension FileManagerView {
    struct SDCardInfo: View {
        let storage: StorageSpace?

        var body: some View {
            HStack(spacing: 32) {
                VStack(alignment: .leading, spacing: 12) {
                    Text("SD Card")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.primary)

                    ProgressBar(storage: storage)

                    HStack {
                        Info(title: "Used", space: storage?.used)
                        Spacer()
                        Info(title: "Total", space: storage?.total)
                    }
                    .padding(.horizontal, 12)
                }

                Image("SDCard")
                    .resizable()
                    .renderingMode(.template)
                    .frame(width: 84, height: 84)
                    .foregroundColor(.primary)
            }
            .padding(12)
            .background(Color.groupedBackground)
            .cornerRadius(12)
        }
    }
}

fileprivate extension FileManagerView.SDCardInfo {
    struct ProgressBar: View {
        let storage: StorageSpace?

        var body: some View {
            Group {
                if let storage {
                    GeometryReader { geometry in
                        HStack(spacing: 0) {
                            Rectangle()
                                .fill(Color.orange)
                                .frame(
                                    width: geometry.size.width
                                        * storage.usedRatio
                                )

                            Rectangle()
                                .fill(Color.orange.opacity(0.3))
                        }
                    }
                } else {
                    AnimatedPlaceholder()
                }
            }
            .frame(height: 8)
            .cornerRadius(4)
        }
    }

    struct Info: View {
        let title: String
        let space: Int?

        var body: some View {
            VStack {
                Text(title)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.black30)

                if let space {
                    Text(space.hr)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.primary)
                } else {
                    AnimatedPlaceholder()
                        .frame(width: 50, height: 10)
                }
            }
        }
    }
}

fileprivate extension StorageSpace {
    var usedRatio: CGFloat {
        guard total > 0 else { return 0 }
        return CGFloat(used) / CGFloat(total)
    }
}

#Preview {
    VStack {
        FileManagerView.SDCardInfo(storage: nil)

        FileManagerView.SDCardInfo(storage: .init(free: 10, total: 40))
    }
    .padding(12)
    .background(Color.background)
}
