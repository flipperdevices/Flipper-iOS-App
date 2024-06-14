import SwiftUI
import AppIntents

struct EntryView: View {
    let entry: Provider.Entry

    var body: some View {
        Toggle(
            isOn: entry.isEmulating,
            intent: EmulateIntent(entity: entry.configuration.entity)
        ) {
        }
        .toggleStyle(MyToggleStyle(entry))
    }
}

struct MyToggle: View {
    let isOn: Bool
    let entry: Provider.Entry

    var name: String {
        entry.configuration.entity.name
    }

    var imageName: String {
        entry.configuration.entity.kind.image
    }

    var body: some View {
        VStack {
            Spacer()

            VStack {
                Image(imageName)
                    .renderingMode(.template)
                    .foregroundStyle(.primary)

                Text(name)
            }

            Spacer()

            if entry.configuration.entity.id == "-" {
                TemplateButton()
            } else if entry.configuration.kind == .emulatable {
                EmulateButton(isEmulating: isOn)
            } else {
                SendButton(isEmulating: isOn)
            }
        }
    }
}

// We want to use LiveActivityIntent to always handle intent in the main app
// But LiveActivityIntent has a huge lag before calling timeline()
// thus widget feels unresponsive like nothing happened
// So we use magic configuration.isOn but it's available in ToggleStyle only

struct MyToggleStyle: ToggleStyle {
    let entry: Entry
    init(_ entry: Entry) {
        self.entry = entry
    }
    func makeBody(configuration: Configuration) -> some View {
        MyToggle(isOn: configuration.isOn, entry: entry)
    }
}
