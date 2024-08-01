import Infrared
import Foundation

public struct InfraredButton: Identifiable {
    public let id: UUID = UUID()

    public let position: InfraredButtonPosition
    public let data: InfraredButtonType

    init(_ button: Infrared.InfraredButton) {
        self.position = InfraredButtonPosition(button)
        self.data = InfraredButtonType(button.data)
    }
}
