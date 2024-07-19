import SwiftUI
import Core
import Infrared

struct InfraredButtonView: View {
    let button: InfraredButton
    let cellLenght: Double

    var body: some View {
        Group {
            switch button.data {
            case .text(let data): TextInfraredButton(data: data)
            case .icon(let data): IconInfraredButton(data: data)
            case .base64Image(let data): Base64ImageInfraredButton(data: data)
            case .navigation(let data): NavigationInfraredButton(data: data)
            case .volume(let data): VolumeInfraredButton(data: data)
            case .channel(let data): ChannelInfraredButton(data: data)
            case .unknown: UnknownInfraredButton()
            }
        }
        .frame(
            width: cellLenght * button.contentWidth,
            height: cellLenght * button.contentHeight
        )
    }
}
