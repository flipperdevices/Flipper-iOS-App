import SwiftUI

struct LazyScrollView<Content: View>: View {
    @State private var isLoadTriggered = false

    private var content: () -> Content
    private var load: @MainActor () async -> Void

    init(
        load: @escaping @MainActor () async -> Void = {},
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.content = content
        self.load = load
    }

    var body: some View {
        GeometryReader { geometry in
            ScrollView {
                content()
                    .anchorPreference(
                        key: OffsetKey.self,
                        value: .bottom
                    ) {
                        geometry.size.height - geometry[$0].y
                    }
            }
            .onPreferenceChange(OffsetKey.self) { offset in
                Task {
                    guard !isLoadTriggered else {
                        return
                    }
                    if offset < 0 {
                        isLoadTriggered = false
                    } else {
                        isLoadTriggered = true
                        await load()
                        isLoadTriggered = false
                    }
                }
            }
        }
    }
}
