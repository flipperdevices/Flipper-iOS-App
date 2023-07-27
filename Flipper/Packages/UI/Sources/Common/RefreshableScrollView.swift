import SwiftUI

struct RefreshableScrollView<Content: View>: View {
    @State private var isRefreshTriggered = false
    @State private var isFinishedTriggered = false
    @State private var offset: Double = 0
    private let threshold: Double = 150.0

    var pullProgress: Double {
        min(1.0, offset / threshold)
    }

    private var isEnabled: Bool
    private var content: () -> Content
    private var refreshAction: @MainActor () -> Void
    private var finishedAction: @MainActor () async -> Void

    init(
        isEnabled: Bool,
        action: @escaping @MainActor () -> Void,
        onEnd: @escaping @MainActor () async -> Void = {},
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.isEnabled = isEnabled
        self.content = content
        self.refreshAction = action
        self.finishedAction = onEnd
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
                        key: TopOffsetPreferenceKey.self,
                        value: .top
                    ) {
                        geometry[$0].y
                    }
                    .anchorPreference(
                        key: BottomOffsetPreferenceKey.self,
                        value: .bottom
                    ) {
                        geometry.size.height - geometry[$0].y
                    }
                }
            }
            .onPreferenceChange(TopOffsetPreferenceKey.self) { offset in
                self.offset = offset
                // TODO: Find the reason why the offset is not 0.0 sometimes
                if offset < 1 {
                    isRefreshTriggered = false
                } else if offset > threshold, !isRefreshTriggered, isEnabled {
                    isRefreshTriggered = true
                    feedback(style: .soft)
                    refreshAction()
                }
            }
            .onPreferenceChange(BottomOffsetPreferenceKey.self) { offset in
                Task {
                    guard !isFinishedTriggered else {
                        return
                    }
                    if offset < 0 {
                        isFinishedTriggered = false
                    } else {
                        isFinishedTriggered = true
                        await finishedAction()
                        isFinishedTriggered = false
                    }
                }
            }
        }
    }
}

private struct TopOffsetPreferenceKey: PreferenceKey {
    typealias Value = Double

    static var defaultValue = Double.zero

    static func reduce(value: inout Value, nextValue: () -> Value) {
        value = nextValue()
    }
}

private struct BottomOffsetPreferenceKey: PreferenceKey {
    typealias Value = Double

    static var defaultValue = Double.zero

    static func reduce(value: inout Value, nextValue: () -> Value) {
        value = nextValue()
    }
}
