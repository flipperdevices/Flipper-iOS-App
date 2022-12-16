import SwiftUI

struct AppsSegments: View {
    @Binding var selected: Segment

    enum Segment {
        case all
        case installed
    }

    var body: some View {
        HStack(spacing: 2) {
            AppsSegment(
                selected: $selected,
                id: .all,
                image: "AllApps",
                title: "All Apps"
            )

            AppsSegment(
                selected: $selected,
                id: .installed,
                image: "InstalledApps",
                title: "Installed"
            )
        }
        .background(.white.opacity(0.3))
        .cornerRadius(8)
    }
}

struct AppsSegment: View {
    @Binding var selected: AppsSegments.Segment

    let id: AppsSegments.Segment

    var isSelected: Bool {
        id == selected
    }

    let image: String
    let title: String

    var body: some View {
        HStack {
            HStack(spacing: 8) {
                Spacer(minLength: 0)
                Image(image)
                    .renderingMode(.template)
                    .foregroundColor(.primary)
                Text(title)
                    .font(.system(size: 12, weight: .bold))
                Spacer(minLength: 0)
            }
            .padding(6)
            .background(isSelected ? Color.a1 : .clear)
            .cornerRadius(8)
        }
        .onTapGesture {
            selected = id
        }
        .padding(2)
    }
}
