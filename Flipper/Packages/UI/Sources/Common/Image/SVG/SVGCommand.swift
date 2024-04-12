import Foundation

enum SVGCommand {
    case moveAbsolute(point: CGPoint) // M
    case moveRelative(x: CGFloat, y: CGFloat) // m

    case lineToAbsolute(point: CGPoint) // L
    case lineToRelative(x: CGFloat, y: CGFloat) // l

    case horizontalLineToAbsolute(x: CGFloat) // H
    case horizontalLineToRelative(x: CGFloat) // h

    case verticalLineToAbsolute(y: CGFloat) // V
    case verticalLineToRelative(y: CGFloat) // v

    case curveToAbsolute(x: CGPoint, y: CGPoint, to: CGPoint) // C

    case rect(rect: CGRect) // rect

    case closePath // Z or z

    case unknown
}
