import SwiftUI

struct NavigationPathKey: EnvironmentKey {
    static let defaultValue: Binding<NavigationPath> =
        .init(get: { .init() }, set: { _ in })
}

extension EnvironmentValues {
    var path: Binding<NavigationPath> {
        get { self[NavigationPathKey.self] }
        set { self[NavigationPathKey.self] = newValue }
    }
}

extension Binding where Value == NavigationPath {
    func append<V>(_ value: V) where V: Hashable {
        wrappedValue.append(value)
    }

    func clear() {
        wrappedValue.removeLast(wrappedValue.count)
    }
}
