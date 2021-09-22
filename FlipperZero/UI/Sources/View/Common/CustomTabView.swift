import SwiftUI

// SwiftUI TabView doesn't support overlay

// TODO: refactor

struct CustomTabView: View {
    @Environment(\.colorScheme) var colorScheme
    @Binding var selected: Tab

    enum Tab {
        case device
        case archive
        case options
    }

    func color(for tab: Tab) -> Color {
        selected == tab ? .accentColor : .secondary
    }

    var body: some View {
        VStack {
            HStack(alignment: .top) {
                VStack {
                    Image("Device")
                        .renderingMode(.template)
                    Text("Device")
                        .font(.system(size: 10, weight: .medium))
                }
                .foregroundColor(color(for: .device))
                .padding(.leading, 30)
                .onTapGesture {
                    self.selected = .device
                }

                Spacer()

                VStack {
                    Image(systemName: "creditcard.fill")
                        .font(.system(size: 24))
                    Text("Archive")
                        .font(.system(size: 10, weight: .medium))
                        .padding(.top, 2)
                }
                .foregroundColor(color(for: .archive))
                .onTapGesture {
                    self.selected = .archive
                }

                Spacer()

                VStack {
                    Image(systemName: "gearshape.fill")
                        .font(.system(size: 24))
                    Text("Options")
                        .font(.system(size: 10, weight: .medium))
                }
                .foregroundColor(color(for: .options))
                .padding(.trailing, 30)
                .onTapGesture {
                    self.selected = .options
                }
            }
            .padding(.bottom, bottomSafeArea)
        }
        .frame(height: tabViewHeight + bottomSafeArea, alignment: .top)
        .background(colorScheme == .light ? Color.white : Color.black)
    }
}
