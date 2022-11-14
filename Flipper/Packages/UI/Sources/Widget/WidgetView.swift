import SwiftUI

public struct WidgetView: View {
    @ObservedObject var viewModel: WidgetViewModel

    var rows: Range<Int> {
        viewModel.isExpanded
            ? (0..<(viewModel.keys.count / 2 + 1))
            : (0..<1)
    }

    public init(viewModel: WidgetViewModel) {
        self.viewModel = viewModel
    }

    public var body: some View {
        VStack(spacing: 0) {
            Divider()
                .foregroundColor(.black4)

            if viewModel.showAppLocked {
                WidgetError(
                    text: "Flipper is Busy",
                    image: "WidgetFlipperBusy",
                    isPresented: $viewModel.showAppLocked
                )
                .padding(.vertical, 14)
            } else if viewModel.showCantConnect {
                WidgetError(
                    text: "Can’t Connect to Flipper",
                    image: "WidgetCantConnect",
                    isPresented: $viewModel.showCantConnect
                )
                .padding(.vertical, 14)
            } else if viewModel.showNotSynced {
                WidgetError(
                    text: "This Key is Not Synced",
                    image: "WidgetKeyNotSynced",
                    isPresented: $viewModel.showNotSynced
                )
                .padding(.vertical, 14)
            } else {
                self.keys
            }
        }
        .onAppear {
            viewModel.connect()
        }
        .onDisappear {
            viewModel.stopEmulate()
            viewModel.disconnect()
        }
        .edgesIgnoringSafeArea(.all)
    }

    var keys: some View {
        ForEach(rows, id: \.self) { row in
            HStack(spacing: 0) {
                let i1 = row * 2
                let i2 = i1 + 1

                ZStack {
                    if i1 < viewModel.keys.count {
                        WidgetKeyView(
                            index: i1,
                            state: viewModel.state(at: i1),
                            viewModel: viewModel)
                    } else {
                        Button {
                            viewModel.addKey()
                        } label: {
                            AddKeyView(viewModel: viewModel)
                        }
                    }
                }
                .padding(.horizontal, 11)
                .padding(.bottom, 4)

                Divider()

                ZStack {
                    if i2 < viewModel.keys.count {
                        WidgetKeyView(
                            index: i2,
                            state: viewModel.state(at: i2),
                            viewModel: viewModel)
                    } else {
                        AddKeyView(viewModel: viewModel)
                            .opacity(i1 < viewModel.keys.count ? 1 : 0)
                    }
                }
                .padding(.horizontal, 11)
                .padding(.bottom, 4)
            }

            if row + 1 < rows.endIndex {
                Divider()
            }
        }
    }
}
