//
//  DesignPlaygroundView.swift
//  Core
//
//  Created by Yachin Ilya on 25.03.2021.
//

import SwiftUI

struct DesignPlaygroundView: View {
    @State var fontSegment: Int = 0
    @State var fontSize: Double = 32
    private let minBound = 10
    private let maxBound = 85
    var body: some View {
        VStack(alignment: .center) {
            Picker("", selection: $fontSegment) {
                Text("HelvetiPixel").tag(0)
                Text("Born2bSportyV2").tag(1)
                Text("Roboto-Regular").tag(2)
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding()
            Slider(
                value: $fontSize,
                in: Double(minBound)...Double(maxBound),
                minimumValueLabel: Text("\(minBound) pt"),
                maximumValueLabel: Text("\(maxBound) pt")) { }
                .padding(.horizontal)
            Text("Current font size is \(Int(fontSize)) pt")
                .font(.footnote)
            Spacer()
            Text("Hello, cruel world. Why you so bleak and gloom?")
                .font(
                    .custom(
                        fontStyle(for: fontSegment).rawValue,
                        size: CGFloat(fontSize))
                )
            Spacer()
        }.padding()
    }

    private func fontStyle(for section: Int) -> CustomFontStyle {
        switch section {
        case 0:
            return .regularPixel
        case 1:
            return .boldPixel
        case 2:
            return .regularRoboto
        default:
            return .regularRoboto
        }
    }
}

struct DesignPlaygroundView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            DesignPlaygroundView()
        }
    }
}
