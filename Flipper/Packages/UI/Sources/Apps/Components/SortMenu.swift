import Core
import SwiftUI

struct SortMenu: View {
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject private var model: Applications

    var color: Color {
        colorScheme == .light
            ? .black8
            : .black80
    }

    var selected: Binding<Applications.SortOption>

    var body: some View {
        Menu {
            ForEach(Applications.SortOption.allCases, id: \.self) { sortOrder in
                Button(sortOrder.rawValue) {
                    selected.wrappedValue = sortOrder
                }
            }
        } label: {
            HStack(spacing: 4) {
                Text(selected.wrappedValue.rawValue)
                    .font(.system(size: 12, weight: .medium))

                Image("ChevronRight")
                    .renderingMode(.template)
                    .rotationEffect(.degrees(90))
            }
            .padding(.vertical, 6)
            .padding(.horizontal, 12)
            .frame(width: 124, height: 26)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .inset(by: 0.5)
                    .stroke(color)
            )
            .foregroundColor(.black30)
        }
    }
}
