import SwiftUI

func feedback() {
    let impactMed = UIImpactFeedbackGenerator(style: .heavy)
    impactMed.impactOccurred()
}
