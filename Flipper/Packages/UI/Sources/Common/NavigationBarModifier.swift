import SwiftUI

struct NavigationBarModifier: ViewModifier {
    let backgroundColor: UIColor?

    init(foregroundColor: UIColor?, backgroundColor: UIColor?) {
        self.backgroundColor = backgroundColor
        let foregroundColor = foregroundColor ?? .white
        let appearance = UINavigationBarAppearance()
        appearance.configureWithTransparentBackground()
        appearance.backgroundColor = backgroundColor
        appearance.titleTextAttributes[.foregroundColor] = foregroundColor
        appearance.largeTitleTextAttributes[.foregroundColor] = foregroundColor

        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().compactAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
        UINavigationBar.appearance().tintColor = foregroundColor
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
            foregroundColor: .init(foreground ?? .primary),
            backgroundColor: .init(background ?? .clear)))
    }
}

// MARK: Fix back swipe with custom back button
// swiftlint:disable override_in_extension

extension UINavigationController: UIGestureRecognizerDelegate {
    override open func viewDidLoad() {
        super.viewDidLoad()
        interactivePopGestureRecognizer?.delegate = self
    }

    public func gestureRecognizerShouldBegin(
        _ gestureRecognizer: UIGestureRecognizer
    ) -> Bool {
        viewControllers.count > 1
    }
}
