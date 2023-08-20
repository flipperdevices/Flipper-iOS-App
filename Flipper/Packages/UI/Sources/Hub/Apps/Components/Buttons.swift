import Core
import SwiftUI

struct UpdateAllAppButton: View {
    @EnvironmentObject var model: Applications

    @State var updatesCount: Int?

    let action: () -> Void

    var body: some View {
        Button {
            action()
        } label: {
            HStack {
                Text("UPDATE ALL")
                    .foregroundColor(.white)
                    .font(.born2bSportyV2(size: 18))

                if let updatesCount {
                    Group {
                        Group {
                            Text("\(updatesCount)")
                                .font(.system(size: 12, weight: .bold))
                                .foregroundColor(.sGreenUpdate)
                                .padding(.horizontal, 4)
                        }
                        .padding(2)
                    }
                    .background(.white.opacity(0.8))
                    .cornerRadius(4)
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: 36)
            .background(Color.sGreenUpdate)
            .cornerRadius(8)
        }
        .onReceive(model.$statuses) { _ in
            loadUpdates()
        }
        .task {
            loadUpdates()
        }
    }

    func loadUpdates() {
        self.updatesCount = model.outdatedCount
    }
}

struct DeleteAppButton: View {
    var action: () -> Void

    var body: some View {
        Button {
            action()
        } label: {
            GeometryReader { proxy in
                Image("AppDelete")
                    .resizable()
                    .frame(
                        width: proxy.size.width,
                        height: proxy.size.height)
            }
        }
    }
}

struct InstallAppButton: View {
    var action: () -> Void

    var body: some View {
        AppActionButton(
            title: "INSTALL",
            color: .a1,
            progress: 1,
            action: action
        )
    }
}

struct UpdateAppButton: View {
    var action: () -> Void

    var body: some View {
        AppActionButton(
            title: "UPDATE",
            color: .sGreenUpdate,
            progress: 1,
            action: action
        )
    }
}

struct InstalledAppButton: View {
    var action: () -> Void = {}

    var body: some View {
        AppActionButton(
            title: "INSTALLED",
            color: .black20,
            progress: 1,
            action: action
        )
        .disabled(true)
    }
}

struct InstallingAppButton: View {
    let progress: Double

    var body: some View {
        AppProgressButton(
            color: .a1,
            progress: progress
        )
    }
}

struct UpdatingAppButton: View {
    let progress: Double

    var body: some View {
        AppProgressButton(
            color: .sGreenUpdate,
            progress: progress
        )
    }
}

struct AppActionButton: View {
    let title: String
    let color: Color
    let progress: Double
    var action: () -> Void

    @Environment(\.isEnabled) var isEnabled

    var body: some View {
        Button {
            action()
        } label: {
            GeometryReader { proxy in
                HStack {
                    Text(title)
                        .foregroundColor(isEnabled ? color : .black20)
                }
                .frame(maxWidth: .infinity)
                .frame(height: proxy.size.height)
                .overlay {
                    // TODO: Use style modifier
                    let width: Double = proxy.size.height < 40 ? 2 : 3

                    RoundedRectangle(cornerRadius: 6)
                        .inset(by: 1)
                        .stroke(isEnabled ? color : .black20, lineWidth: width)
                }
            }
        }
    }
}

struct AppProgressButton: View {
    let color: Color
    let progress: Double

    var radius: Double { 6 }

    private var progressText: String {
        "\(Int(progress * 100))%"
    }

    init(color: Color, progress: Double) {
        self.color = color
        self.progress = progress
    }

    var body: some View {
        GeometryReader { proxy in
            ZStack {
                // TODO: Use style modifier
                let lineWidth: Double = proxy.size.height < 40 ? 2 : 3

                RoundedRectangle(cornerRadius: radius)
                    .inset(by: lineWidth / 2)
                    .stroke(color, lineWidth: lineWidth)

                GeometryReader { reader in
                    color
                        .frame(width: reader.size.width * progress)
                        .opacity(0.3)
                }

                VStack(alignment: .center) {
                    Text(progressText)
                        .foregroundColor(color)
                        .padding(.bottom, 2)
                }
            }
            .frame(height: proxy.size.height)
            .cornerRadius(radius)
        }
    }
}
