import UIKit
import SwiftUI

struct LaunchScreenView: UIViewControllerRepresentable {
    typealias UIViewControllerType = UIViewController

    func makeUIViewController(context: Context) -> UIViewController {
        let sb = UIStoryboard(name: "LaunchScreen", bundle: nil)
        return sb.instantiateInitialViewController() ?? .init()
    }

    func updateUIViewController(
        _ uiViewController: UIViewController,
        context: Context
    ) {
    }
}
