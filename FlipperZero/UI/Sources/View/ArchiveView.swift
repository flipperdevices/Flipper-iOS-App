import SwiftUI

struct ArchiveView: View {
    @ObservedObject var viewModel: ArchiveViewModel

    init(viewModel: ArchiveViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {
        VStack(alignment: .center) {
            List {
                ArchiveListItemView()
            }
        }
    }
}

struct ArchiveListItemView: View {
    var body: some View {
        HStack(spacing: 15) {
            Image(systemName: "wifi.circle")
                .resizable()
                .frame(width: 23, height: 23)
                .rotationEffect(.degrees(90))
                .scaledToFit()
            VStack(spacing: 10) {
                HStack {
                    Text("Moms_bank_card")
                        .bold()
                    Spacer()
                    Image(systemName: "star.fill")
                        .foregroundColor(.secondary)
                }

                HStack {
                    Text("ID: 031,33351")
                    Spacer()
                    Text("Mifare")
                    Image(systemName: "checkmark")
                        .foregroundColor(.secondary)
                }
            }
        }
    }
}

struct ArchiveView_Previews: PreviewProvider {
    static var previews: some View {
        ArchiveView(viewModel: .init())
    }
}
