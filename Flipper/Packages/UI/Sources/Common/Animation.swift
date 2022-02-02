import Lottie
import SwiftUI

struct Animation: UIViewRepresentable {
    let name: String
    let loopMode: LottieLoopMode

    init(_ name: String, loopMode: LottieLoopMode = .loop) {
        self.name = name
        self.loopMode = loopMode
    }

    func makeUIView(context: UIViewRepresentableContext<Animation>) -> UIView {
        let animationView = AnimationView()
        animationView.animation = .named(name)
        animationView.contentMode = .scaleAspectFit
        animationView.loopMode = loopMode
        animationView.play()

        let view = UIView(frame: .zero)
        view.addSubview(animationView)

        animationView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            animationView.widthAnchor.constraint(equalTo: view.widthAnchor),
            animationView.heightAnchor.constraint(equalTo: view.heightAnchor)
        ])

        return view
    }

    func updateUIView(
        _ uiView: UIView,
        context: UIViewRepresentableContext<Animation>
    ) {
    }
}
