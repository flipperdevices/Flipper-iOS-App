import SwiftUI

struct ZoomScreenshot: View {
    let screenshot: URL
    @Binding var currentIndex: Int
    let onSwipeRight: () -> Void
    let onSwipeLeft: () -> Void

    private var sensitivity: CGFloat { 0.7 }
    private var cornerRadius: Double { 8 }

    @GestureState private var magnifyBy = 1.0
    @State private var currentScale: CGFloat = 1.0

    @State private var offset: CGSize = .zero
    @State private var lastOffset: CGSize = .zero
    @State private var imageSize: CGSize = .zero

    var body: some View {
        GeometryReader { geometry in
            VStack {
                Spacer()
                CachedAsyncImage(url: screenshot) { image in
                    Image(uiImage: image)
                        .interpolation(.none)
                        .resizable()
                        .scaledToFit()
                        .padding(cornerRadius / 2)
                } placeholder: {
                    AnimatedPlaceholder()
                        .aspectRatio(2, contentMode: .fit)
                }
                .padding(cornerRadius / 2 )
                .background(
                    ZStack {
                        RoundedRectangle(cornerRadius: cornerRadius)
                            .fill(Color.a1)
                            .padding(1)

                        RoundedRectangle(cornerRadius: cornerRadius)
                            .stroke(.black, lineWidth: 2)
                            .padding(1)

                        GeometryReader { proxy in
                            Color.clear
                                .onAppear {
                                    imageSize = proxy.size
                                }
                        }
                    }
                )
                Spacer()
            }
            .offset(offset)
            .scaleEffect(currentScale * magnifyBy)
            .gesture(
                SimultaneousGesture(
                    MagnificationGesture()
                        .updating($magnifyBy) { value, state, _ in
                            state = value
                        }
                        .onEnded { value in
                            onMagnifyEnd(geometry: geometry, scale: value)
                        },
                    DragGesture()
                        .onChanged { value in
                            onDragChange(geometry: geometry, value: value)
                        }
                        .onEnded { _ in onDragEnd() }
                )
            )
            .gesture(
                SpatialTapGesture(count: 2, coordinateSpace: .local)
                    .onEnded { onDoubleTapEnd(geometry: geometry, event: $0) }
            )
            .simultaneousGesture(
                DragGesture(minimumDistance: 10, coordinateSpace: .global)
                    .onEnded(onSwipe)
            )
            .onChange(of: currentIndex) { _ in resetGesture() }
            .padding(.horizontal, 24)
        }
    }

    private func resetGesture() {
        currentScale = 1
        offset = .zero
        lastOffset = .zero
    }

    private func onMagnifyEnd(geometry: GeometryProxy, scale: CGFloat) {
        let maxScale = geometry.size.height / imageSize.height
        currentScale *= scale

        switch currentScale {
        case ...1:
            resetGesture()
        case maxScale...:
            withAnimation {
                offset = .zero
                lastOffset = .zero
                currentScale = maxScale
            }
        default:
            break
        }
    }

    private func onDragChange(
        geometry: GeometryProxy,
        value: DragGesture.Value
    ) {
        guard currentScale > 1 else { return }
        var newOffset = value.translation / currentScale + lastOffset
        let horizontalDirection = value.translation.width

        let imageSize = imageSize * currentScale
        let verticalLine = (geometry.size.width - imageSize.width) / 2
        let horizontalLine = (geometry.size.height - imageSize.height) / 2

        let leftDistance = verticalLine + newOffset.width * currentScale
        let rightDistance = verticalLine - newOffset.width * currentScale

        let topDistance = horizontalLine + newOffset.height * currentScale
        let bottomDistance = horizontalLine - newOffset.height * currentScale

        if topDistance < 0 || bottomDistance < 0 {
            newOffset.height = offset.height
        }

        if geometry.size.width >= imageSize.width * currentScale {
            if horizontalDirection >= 0 && rightDistance <= 0 {
                newOffset.width = offset.width
            } else if horizontalDirection <= 0 && leftDistance <= 0 {
                newOffset.width = offset.width
            }
        } else {
            if horizontalDirection >= 0 && leftDistance >= 0 {
                newOffset.width = offset.width
            } else if horizontalDirection <= 0 && rightDistance >= 0 {
                newOffset.width = offset.width
            }
        }

        offset = newOffset
    }

    private func onDragEnd() {
        if currentScale > 1 {
            lastOffset = offset
        } else {
            offset = .zero
            lastOffset = .zero
        }
    }

    private func onDoubleTapEnd(
        geometry: GeometryProxy,
        event: SpatialTapGesture.Value
    ) {
        if currentScale > 1 {
            withAnimation { resetGesture() }
        } else {
            let newWidth = geometry.size.width / 2 - event.location.x
            let newScale = geometry.size.height / imageSize.height

            withAnimation {
                offset = CGSize(width: newWidth, height: 0)
                lastOffset = offset
                currentScale = newScale
            }
        }
    }

    private func onSwipe(value: DragGesture.Value) {
        guard currentScale == 1 else { return }

        let horizontal = value.translation.width
        let vertical = value.translation.height
        guard abs(horizontal) > abs(vertical) else { return }

        if horizontal < 0 {
            onSwipeRight()
        } else {
            onSwipeLeft()
        }
        resetGesture()
    }
}

extension CGSize {
    static func + (lhs: CGSize, rhs: CGSize) -> CGSize {
        return CGSize(
            width: lhs.width + rhs.width,
            height: lhs.height + rhs.height
        )
    }

    static func * (lhs: CGSize, rhs: CGFloat) -> CGSize {
        return CGSize(
            width: lhs.width * rhs,
            height: lhs.height * rhs
        )
    }

    static func / (lhs: CGSize, rhs: CGFloat) -> CGSize {
        return CGSize(
            width: lhs.width / rhs,
            height: lhs.height / rhs
        )
    }
}
