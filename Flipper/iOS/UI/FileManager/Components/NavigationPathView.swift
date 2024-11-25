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

        var body: some View {
            HStack(spacing: 8) {
                Image("SDCard")
                    .resizable()
                    .renderingMode(.template)
                    .frame(width: 24, height: 24)
                    .foregroundColor(.primary)
                    .onTapGesture { navigate(to: 0) }

                Text("/")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.black30)

                ScrollViewReader { proxy in
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            ForEach(components.indices, id: \.self) { index in
                                Element(
                                    component: components[index],
                                    index: index,
                                    onTap: navigate
                                )
                            }
                        }
                    }
                    .onAppear {
                        if let lastIndex = components.indices.last {
                            proxy.scrollTo(lastIndex, anchor: .trailing)
                        }
                    }
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
                if index != 0 {
                    Text("/")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.black30)
                }

                Text(component)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.primary)
                    .onTapGesture { onTap(index + 1) }
            }
            .id(index)
        }
    }
}
