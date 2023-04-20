import SwiftUI

func feedback(style: UIImpactFeedbackGenerator.FeedbackStyle) {
    let impactMed = UIImpactFeedbackGenerator(style: style)
    impactMed.impactOccurred()
}
