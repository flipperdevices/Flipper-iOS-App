import SwiftUI

struct UpdateAllAppButton: View {
    let action: () -> Void

    var body: some View {
        Button {
            action()
        } label: {
            HStack {
                Text("UPDATE ALL")
                    .foregroundColor(.white)
                    .font(.born2bSportyV2(size: 18))
            }
            .frame(maxWidth: .infinity)
            .frame(height: 36)
            .background(Color.sGreenUpdate)
            .cornerRadius(8)
        }
    }
}

struct InstallAppButton: View {
    var action: () -> Void

    var body: some View {
        AppActionButton(title: "INSTALL", color: .a1, action: action)
    }
}

struct UpdateAppButton: View {
    var action: () -> Void

    var body: some View {
        AppActionButton(title: "UPDATE", color: .sGreenUpdate, action: action)
    }
}

struct InstalledAppButton: View {
    var body: some View {
        // swiftlint:disable trailing_closure
        AppActionButton(title: "INSTALLED", color: .black20, action: {})
            .disabled(true)
    }
}

struct AppActionButton: View {
    let title: String
    let color: Color
    var action: () -> Void

    var body: some View {
        Button {
            action()
        } label: {
            HStack {
                Text(title)
                    .foregroundColor(.white)
                    .font(.born2bSportyV2(size: 18))
            }
            .frame(width: 116, height: 32)
            .background(color)
            .cornerRadius(6)
        }
    }
}
