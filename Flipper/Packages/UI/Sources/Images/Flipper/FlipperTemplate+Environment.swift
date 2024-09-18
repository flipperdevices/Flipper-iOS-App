import SwiftUI
import Peripheral

extension EnvironmentValues {
    @Entry var flipperStyle: FlipperTemplate.Style = .white
    @Entry var flipperState: FlipperTemplate.State = .normal
}

extension View {
    func flipperStyle(_ style: FlipperTemplate.Style) -> some View {
        self.environment(\.flipperStyle, style)
    }

    func flipperState(_ state: FlipperTemplate.State) -> some View {
        self.environment(\.flipperState, state)
    }
}

extension View {
    func flipperColor(_ color: FlipperColor?) -> some View {
        self.environment(\.flipperStyle, .init(color))
    }
}

extension FlipperTemplate.Style {
    init(_ source: FlipperColor?) {
        switch source {
        case .some(.white): self = .white
        case .some(.black): self = .black
        case .some(.clear): self = .clear
        default: self = .white
        }
    }
}
