import SwiftUI
import Peripheral

extension FileManagerView {
    struct NavigationPathView: View {
        @Environment(\.path) private var navigationPath

        let path: Peripheral.Path

        private var components: [String] {
            path
                .string
                .split(separator: "/")
                .map(String.init)
                .filter { $0 != "ext" }
        }

        var gradient: LinearGradient {
            LinearGradient(
                gradient: Gradient(
                    stops: [
                        Gradient.Stop(color: .background, location: 0.2),
                        Gradient.Stop(color: .clear, location: 1),
                    ]
                ),
                startPoint: .leading,
                endPoint: .trailing
            )
        }

        var body: some View {
            HStack(spacing: 0) {
                Image("SDCardDummy")
                    .resizable()
                    .renderingMode(.template)
                    .frame(width: 20, height: 24)
                    .foregroundColor(.primary)
                    .onTapGesture { navigate(to: 0) }

                ZStack(alignment: .leading) {
                    ScrollViewReader { proxy in
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 8) {
                                Spacer()
                                    .frame(width: 0, height: 0)

                                ForEach(
                                    components.indices,
                                    id: \.self
                                ) { index in
                                    Element(
                                        component: components[index],
                                        index: index,
                                        onTap: navigate
                                    )
                                    .id(index)
                                }
                            }
                        }
                        .onAppear {
                            if let lastIndex = components.indices.last {
                                proxy.scrollTo(lastIndex, anchor: .trailing)
                            }
                        }
                    }

                    Rectangle()
                        .fill(gradient)
                        .frame(width: 8, height: 24)
                }
            }
        }

        private func navigate(to index: Int) {
            let stack = navigationPath.wrappedValue.count
            navigationPath.wrappedValue.removeLast(stack - index - 1)
        }
    }
}

fileprivate extension FileManagerView.NavigationPathView {
    struct Element: View {
        let component: String
        let index: Int
        let onTap: (Int) -> Void

        var body: some View {
            HStack(spacing: 8) {
                Text("/")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.black30)

                Text(component)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.primary)
                    .onTapGesture { onTap(index + 1) }
            }
        }
    }
}

#Preview {
    VStack {
        FileManagerView.NavigationPathView(
            path: Peripheral.Path(string: "/ext/apps")
        )

        FileManagerView.NavigationPathView(
            path: Peripheral.Path(string: "/ext/Downloads/2021/08/17")
        )

        FileManagerView.NavigationPathView(
            path: Peripheral.Path(
                string: "/ext/Downloads/2021/08/17/dummy/test/file"
            )
        )
    }
    .environment(\.path, .constant(NavigationPath()))
    .padding(12)
    .background(Color.background)
}
