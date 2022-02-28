import SwiftUI

struct NavigationBarModifier: ViewModifier {
    let backgroundColor: UIColor?

    init(tintColor: UIColor?, backgroundColor: UIColor?) {
        self.backgroundColor = backgroundColor
        let appearance = UINavigationBarAppearance()
        appearance.configureWithTransparentBackground()
        appearance.backgroundColor = backgroundColor
        appearance.titleTextAttributes = [.foregroundColor: UIColor.white]
        appearance.largeTitleTextAttributes = [.foregroundColor: UIColor.white]

        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().compactAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
        UINavigationBar.appearance().tintColor = tintColor
    }

    func body(content: Content) -> some View {
        ZStack {
            content
            VStack {
                GeometryReader { geometry in
                    Color(backgroundColor ?? .clear)
                        .frame(height: geometry.safeAreaInsets.top)
                        .edgesIgnoringSafeArea(.top)
                    Spacer()
                }
            }
        }
    }
}

extension View {
    func navigationBarColors(
        foreground: Color?,
        background: Color?
    ) -> some View {
        self.modifier(NavigationBarModifier(
            tintColor: .init(foreground ?? .primary),
            backgroundColor: .init(background ?? .clear)))
    }
}
