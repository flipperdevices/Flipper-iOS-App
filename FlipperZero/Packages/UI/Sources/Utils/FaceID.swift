import SwiftUI
import LocalAuthentication

extension UIDevice {
    static var isFaceIDAvailable: Bool {
        if #available(iOS 11.0, *) {
            let context = LAContext()
            return
                context.canEvaluatePolicy(.deviceOwnerAuthentication, error: nil)
                && context.biometryType == .faceID
        }
        return false
    }
}
