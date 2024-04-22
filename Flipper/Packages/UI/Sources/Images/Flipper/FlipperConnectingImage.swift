import SwiftUI

struct FlipperConnectingImage: View {
    private var flipperDefaultHeight: Double { 100.0 }
    private var flipperDefaultWidth: Double { 238.0 }

    private var imageWidthPaddingPercent: Double {
        61.2 / flipperDefaultWidth
    }

    private var imageHeightPaddingPercent: Double {
        11 / flipperDefaultHeight
    }

    private var imageWidthPercent: Double {
        84 / flipperDefaultWidth
    }

    private var imageHeightPercent: Double {
        46.1 / flipperDefaultHeight
    }
    
    private var imageRoundCornerPercent: Double {
        2.8 / flipperDefaultWidth
    }

    @State var frame: CGSize = .zero

    var body: some View {
        ZStack(alignment: .topLeading) {
            FlipperTemplate()
                .flipperState(.disabled)
                .background(
                     GeometryReader { geometryProxy in
                         Color.clear.onAppear {
                             frame = geometryProxy.size
                         }
                     }
                   )

            AnimatedPlaceholder()
                .cornerRadius(frame.width * imageRoundCornerPercent)
                .offset(
                    x: frame.width * imageWidthPaddingPercent,
                    y: frame.height * imageHeightPaddingPercent
                )
                .frame(
                    width: frame.width * imageWidthPercent,
                    height: frame.height * imageHeightPercent
                )
        }
    }
}
