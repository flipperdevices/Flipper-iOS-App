import SwiftUI

struct WidgetSettingsView: View {
    @StateObject var viewModel: WidgetSettingsViewModel
    @Environment(\.dismiss) private var dismiss

    var rows: Range<Int> {
        (0..<(viewModel.keys.count / 2 + 1))
    }

    var body: some View {
        VStack(spacing: 0) {
            ZStack(alignment: .center) {
                Text("Widget Settings")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.primary)

                HStack {
                    Spacer()
                    Button {
                        dismiss()
                    } label: {
                        Text("Done")
                            .font(.system(size: 17, weight: .regular))
                    }
                }
            }
            .padding(.vertical, 10.5)
            .padding(.horizontal, 14)

            ScrollView {
                VStack(spacing: 0) {
                    ForEach(rows, id: \.self) { row in
                        HStack {
                            let i1 = row * 2
                            let i2 = i1 + 1

                            if i1 < viewModel.keys.count {
                                SettingsWidgetKeyView(key: viewModel.keys[i1]) {
                                    viewModel.delete(at: i1)
                                }
                                .padding(11)
                            } else {
                                SettingsAddKeyView() {
                                    viewModel.showAddKey()
                                }
                                .padding(11)
                            }

                            Divider()

                            if i2 < viewModel.keys.count {
                                SettingsWidgetKeyView(key: viewModel.keys[i2]) {
                                    viewModel.delete(at: i2)
                                }
                                .padding(11)
                            } else if i1 < viewModel.keys.count {
                                SettingsAddKeyView {
                                    viewModel.showAddKey()
                                }
                                .padding(11)
                            } else {
                                SettingsAddKeyView {
                                    viewModel.showAddKey()
                                }
                                .padding(11)
                                .opacity(0)
                            }
                        }

                        if row + 1 < rows.endIndex {
                            Divider()
                        }
                    }
                }
                .sheet(isPresented: $viewModel.showAddKeyView) {
                    SettingsSelectKeyView(viewModel: .init(
                        widgetKeys: viewModel.keys
                    ) {
                        viewModel.addKey($0)
                    })
                }
                .background(Color.groupedBackground)
                .cornerRadius(22)
                .padding(14)
            }

            HStack {
                Text("How to add widget on iPhone")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.black40)
                Spacer()
                        .frame(width: 4)
                Image("WidgetQuestion")
                        .resizable()
                        .frame(width: 18, height: 18)
            }
            .onTapGesture {
                viewModel.showHelp()
            }
            .padding(14)
        }
        .sheet(isPresented: $viewModel.showWidgetHelpView) {
            WidgetHelp()
        }
        .background(Color.background)
    }
}
