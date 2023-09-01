import SwiftUI
import LocalAuthentication

extension UIDevice {
    static var isFaceIDAvailable: Bool {
        let context = LAContext()
        return context.canEvaluatePolicy(.deviceOwnerAuthentication, error: nil)
            && context.biometryType == .faceID
    }
}
