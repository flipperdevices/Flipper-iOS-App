//
//  FontExtension.swift
//  FlipperZero
//
//  Created by Yachin Ilya on 14.11.2020.
//

import SwiftUI

extension Font {
    /// Sets `HelvetiPixel` font of visually similar size to iOS body text style
    /// and binds its dynamic size to `Font.TextStyle.body`.
    ///
    /// Compensating the size of pixelated fonts.
    /// According to [HIG Typography section]
    /// (https://developer.apple.com/design/human-interface-guidelines/ios/visual-design/typography)
    /// the default font size is 17 points, but pixelized fonts provide are visually smaller.
    /// It looks almost same size with SF Mono of size 17 when the size multiplied 1.5 times,
    /// hence 25.5 points are used as default.
    /// - Parameter size: Font size in points.
    static func regularPixel(_ size: CGFloat = 25.5) -> Font { custom(.regularPixel, size: size) }

    /// Sets `Born2bSportyV2` font of visually similar size to iOS body text style
    /// and binds its dynamic size to `Font.TextStyle.body`.
    ///
    /// Compensating the size of pixelated fonts.
    /// According to [HIG Typography section]
    /// (https://developer.apple.com/design/human-interface-guidelines/ios/visual-design/typography)
    /// the default font size is 17 points, but pixelized fonts provide are visually smaller.
    /// It looks almost same size with SF Mono of size 17 when the size multiplied 1.5 times,
    /// hence 25.5 points are used as default.
    /// - Parameter size: Font size in points.
    static func boldPixel(_ size: CGFloat = 25.5) -> Font { custom(.boldPixel, size: size) }

    /// Sets `Roboto-Regular` font and binds its dynamic size to `Font.TextStyle.body`.
    ///
    /// According to [HIG Typography section]
    /// (https://developer.apple.com/design/human-interface-guidelines/ios/visual-design/typography)
    /// the default font size is 17 points.
    /// - Parameter size: Font size in points.
    static func regularRoboto(_ size: CGFloat = 17) -> Font { custom(.regularRoboto, size: size) }

    /// Set project specific fonts.
    ///
    /// According to [HIG Typography section]
    /// (https://developer.apple.com/design/human-interface-guidelines/ios/visual-design/typography)
    /// the default font size is 17 points.
    /// - Parameter customStyle: Value of enum type containing all the custom fonts of the project.
    /// - Parameter size: Font size in points.
    /// - Parameter style: `Font.TextStyle` to bind dynamic resizing behavior to.
    static func custom(
        _ customStyle: CustomFontStyle,
        size: CGFloat = 17,
        relativeTo style: Font.TextStyle = .body) -> Font {
        .custom(customStyle.rawValue, size: size, relativeTo: style)
    }
}

enum CustomFontStyle: String {
    case boldPixel     = "Born2bSportyV2"
    case regularPixel  = "HelvetiPixel"
    case regularRoboto = "Roboto-Regular"
}
