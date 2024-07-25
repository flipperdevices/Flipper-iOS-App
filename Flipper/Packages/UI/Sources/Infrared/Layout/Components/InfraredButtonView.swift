import SwiftUI
import Core

struct InfraredButtonView: View {
    let button: InfraredButton
    let cellLenght: Double

    var body: some View {
        InfraredButtonTypeView(data: button.data)
            .frame(
                width: cellLenght * button.position.contentHeight,
                height: cellLenght * button.position.contentHeight
            )
    }
}


struct InfraredButtonTypeView: View {
    let data: InfraredButtonType

    var body: some View {
        switch data {
        case .text(let data): TextInfraredButton(data: data)
        case .icon(let data): IconInfraredButton(data: data)
        case .base64Image(let data): Base64ImageInfraredButton(data: data)
        case .navigation(let data): NavigationInfraredButton(data: data)
        case .volume(let data): VolumeInfraredButton(data: data)
        case .channel(let data): ChannelInfraredButton(data: data)
        case .unknown: UnknownInfraredButton()
        }
    }
}
