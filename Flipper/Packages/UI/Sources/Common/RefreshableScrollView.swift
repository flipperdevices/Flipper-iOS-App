import SwiftUI

struct RefreshableScrollView<Content: View>: View {
    @State private var offset: Double = 0
    private let threshold: Double = 50.0

    var pullProgress: Double {
        min(1.0, offset / threshold)
    }

    private var isEnabled: Bool
    private var content: () -> Content
    private var refreshAction: @MainActor () -> Void

    init(
        isEnabled: Bool,
        action: @escaping @MainActor () -> Void,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.isEnabled = isEnabled
        self.content = content
        self.refreshAction = action
    }

    var body: some View {
        GeometryReader { geometry in
            ScrollView {
                ZStack(alignment: .top) {
                    HStack {
                        Image(systemName: "arrow.counterclockwise")
                            .rotationEffect(.degrees(-90))
                            .rotationEffect(.degrees(-450 * pullProgress))
                        Text("Pull to refresh")
                    }
                    .offset(y: -25)
                    .opacity(isEnabled ? pullProgress : 0)

                    VStack {
                        content()
                    }
                    .anchorPreference(
                        key: OffsetPreferenceKey.self,
                        value: .top
                    ) {
                        geometry[$0].y
                    }
                }
            }
            .onPreferenceChange(OffsetPreferenceKey.self) { offset in
                self.offset = offset
                if offset > threshold {
                    refreshAction()
                }
            }
        }
    }
}

private struct OffsetPreferenceKey: PreferenceKey {
    typealias Value = Double

    static var defaultValue = Double.zero

    static func reduce(value: inout Value, nextValue: () -> Value) {
        value = nextValue()
    }
}
