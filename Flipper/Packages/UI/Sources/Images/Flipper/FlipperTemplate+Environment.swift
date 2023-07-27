import SwiftUI
import Peripheral

struct FlipperStyleKey: EnvironmentKey {
    static let defaultValue: FlipperTemplate.Style = .white
}

struct FlipperStateKey: EnvironmentKey {
    static let defaultValue: FlipperTemplate.State = .normal
}

extension EnvironmentValues {
    var flipperStyle: FlipperTemplate.Style {
        get { self[FlipperStyleKey.self] }
        set { self[FlipperStyleKey.self] = newValue }
    }

    var flipperState: FlipperTemplate.State {
        get { self[FlipperStateKey.self] }
        set { self[FlipperStateKey.self] = newValue }
    }
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
        self.environment(\.flipperStyle, color == .black ? .black : .white)
    }
}
