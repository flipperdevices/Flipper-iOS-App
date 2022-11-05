import SwiftUI

struct NavBar<Leading: View, Principal: View, Trailing: View>: View {
    var leading: () -> Leading?
    var principal: () -> Principal?
    var trailing: () -> Trailing?

    init(
        @ViewBuilder leading: @escaping () -> Leading? = { EmptyView() },
        @ViewBuilder principal: @escaping () -> Principal? = { EmptyView() },
        @ViewBuilder trailing: @escaping () -> Trailing? = { EmptyView() }
    ) {
        self.leading = leading
        self.principal = principal
        self.trailing = trailing
    }

    var body: some View {
        ZStack {
            HStack(spacing: 0) {
                leading()
                Spacer()
            }

            HStack(spacing: 0) {
                Spacer()
                principal()
                Spacer()
            }

            HStack(spacing: 0) {
                Spacer()
                trailing()
            }
        }
        .frame(height: 44)
    }
}

extension View {
    func navbar(@ViewBuilder content: () -> some View) -> some View {
        VStack(spacing: 0) {
            content()
            self
            Spacer()
        }
    }
}
