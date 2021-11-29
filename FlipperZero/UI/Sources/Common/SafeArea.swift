import SwiftUI

extension View {
    var bottomSafeArea: Double { UIDevice.isFaceIDAvailable ? 34 : 0 }
    var tabViewHeight: Double { 49 }
}

extension View {
    var navigationBarHeight: Double {
        let root = UIViewController(nibName: nil, bundle: nil)
        return UINavigationController(rootViewController: root)
            .navigationBar
            .frame
            .size
            .height
    }
}
