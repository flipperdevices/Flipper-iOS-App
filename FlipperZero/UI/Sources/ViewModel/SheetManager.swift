import Combine
import SwiftUI

protocol SheetProtocol: ObservableObject {
    var sheet: PassthroughSubject<AnyView, Never> { get }

    func present(@ViewBuilder content: @escaping () -> AnyView)
}

class SheetManager: SheetProtocol {
    static let shared: SheetManager = .init()

    var sheet: PassthroughSubject<AnyView, Never> = .init()

    func present<Content: View>(content: @escaping () -> Content) {
        sheet.send(AnyView(content()))
    }
}
