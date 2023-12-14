import Core
import SwiftUI

struct AppsSegments: View {
    @EnvironmentObject var model: Applications

    @Binding var selected: Segment

    enum Segment {
        case all
        case installed
    }

    @State var updatesCount: Int = 0

    @Namespace private var animation

    var body: some View {
        HStack(spacing: 2) {
            AppsSegment(
                selected: $selected,
                id: .all,
                image: "AllApps",
                title: "All Apps",
                namespace: animation
            )

            AppsSegment(
                selected: $selected,
                id: .installed,
                image: "InstalledApps",
                title: "Installed",
                badge: updatesCount == 0 ? nil : "\(updatesCount)",
                namespace: animation
            )
        }
        .background(.white.opacity(0.3))
        .cornerRadius(10)
        .onReceive(model.$statuses) { _ in
            Task {
                loadUpdates()
            }
        }
        .task {
            loadUpdates()
        }
    }

    func loadUpdates() {
        self.updatesCount = model.outdatedCount
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
    let badge: String?

    let namespace: Namespace.ID

    init(
        selected: Binding<AppsSegments.Segment>,
        id: AppsSegments.Segment,
        image: String,
        title: String,
        badge: String? = nil,
        namespace: Namespace.ID
    ) {
        self._selected = selected
        self.id = id
        self.image = image
        self.title = title
        self.badge = badge
        self.namespace = namespace
    }

    var body: some View {
        HStack(spacing: 8) {
            Spacer(minLength: 0)
            ZStack {
                Image(image)
                    .renderingMode(.template)
                    .foregroundColor(.primary)

                if let badge {
                    Badge(text: badge)
                        .offset(x: 8, y: -7)
                }
            }
            Text(title)
                .font(.system(size: 12, weight: .bold))
            Spacer(minLength: 0)
        }
        .padding(6)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(isSelected ? Color.a1 : .clear)
                .matchedGeometryEffect(
                    id: "Segment",
                    in: namespace,
                    properties: .frame,
                    isSource: isSelected
                )
        )
        .onTapGesture {
            withAnimation(.linear(duration: 0.1)) {
                selected = id
            }
        }
        .padding(2)
    }

    struct Badge: View {
        let text: String

        var body: some View {
            Text(text)
                .font(.system(size: 8, weight: .bold))
                .foregroundColor(.white)
                .padding(.horizontal, 5)
                .padding(.vertical, 3)
                .background(Color.sGreenUpdate)
                .cornerRadius(60)
                .overlay(
                    RoundedRectangle(cornerRadius: 60)
                        .inset(by: 0.5)
                        .stroke(.white, lineWidth: 1)
                )
        }
    }
}
