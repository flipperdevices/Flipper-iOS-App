import Core
import SwiftUI

struct WidgetSettingsView: View {
    @EnvironmentObject private var widgetService: WidgetService
    @Environment(\.dismiss) private var dismiss

    @State var showAddKeyView = false
    @State var showWidgetHelpView = false

    var rows: Range<Int> {
        (0..<(widgetService.keys.count / 2 + 1))
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

                            if i1 < widgetService.keys.count {
                                WidgetAddedItem(key: widgetService.keys[i1]) {
                                    widgetService.delete(at: i1)
                                }
                                .padding(11)
                            } else {
                                WidgetAddButton() {
                                    showAddKeyView = true
                                }
                                .padding(11)
                            }

                            Divider()

                            if i2 < widgetService.keys.count {
                                WidgetAddedItem(key: widgetService.keys[i2]) {
                                    widgetService.delete(at: i2)
                                }
                                .padding(11)
                            } else if i1 < widgetService.keys.count {
                                WidgetAddButton {
                                    showAddKeyView = true
                                }
                                .padding(11)
                            } else {
                                WidgetAddButton {
                                    showAddKeyView = true
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
                .sheet(isPresented: $showAddKeyView) {
                    WidgetAddKeyView(widgetKeys: widgetService.keys) {
                        widgetService.add($0)
                    }
                }
                .background(Color.groupedBackground)
                .cornerRadius(22)
                .padding(14)
            }

            HStack(spacing: 4) {
                Text("How to add widget on iPhone")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.black40)
                Image("WidgetHelpQuestion")
                    .resizable()
                    .frame(width: 18, height: 18)
            }
            .onTapGesture {
                showWidgetHelpView = true
            }
            .padding(14)
        }
        .sheet(isPresented: $showWidgetHelpView) {
            SettingsWidgetHelpView()
        }
        .background(Color.background)
    }
}
