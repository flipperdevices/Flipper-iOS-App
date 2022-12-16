import Core
import SwiftUI

struct SortMenu: View {
    @EnvironmentObject var model: Applications

    typealias SortOrder = Applications.SortOrder

    var body: some View {
        Menu {
            ForEach(SortOrder.allCases, id: \.self) { sortOrder in
                Button(sortOrder.rawValue) {
                    model.sortOrder = sortOrder
                }
            }
        } label: {
            HStack(spacing: 4) {
                Text(model.sortOrder.rawValue)
                    .font(.system(size: 12, weight: .medium))

                Image("ChevronRight")
                    .renderingMode(.template)
                    .rotationEffect(.degrees(90))
            }
            .padding(.vertical, 6)
            .padding(.horizontal, 12)
            .frame(width: 120, height: 26)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color.black4)
            )
            .foregroundColor(.black30)
        }
    }
}
