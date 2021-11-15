import UIKit

public struct Pixel {
    var a: UInt8
    var r: UInt8
    var g: UInt8
    var b: UInt8
}

extension UIImage {
    convenience init?(pixels: [Pixel], width: Int, height: Int) {
        guard width > 0 && height > 0, pixels.count == width * height else {
            return nil
        }
        var pixels = pixels
        let data = Data(
            bytes: &pixels,
            count: pixels.count * MemoryLayout<Pixel>.size) as CFData
        guard let provider = CGDataProvider(data: data) else {
            return nil
        }
        guard let cgim = CGImage(
            width: width,
            height: height,
            bitsPerComponent: 8,
            bitsPerPixel: 32,
            bytesPerRow: width * MemoryLayout<Pixel>.size,
            space: CGColorSpaceCreateDeviceRGB(),
            bitmapInfo: CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedFirst.rawValue),
            provider: provider,
            decode: nil,
            shouldInterpolate: true,
            intent: .defaultIntent)
        else { return nil }
        self.init(cgImage: cgim)
    }
}
