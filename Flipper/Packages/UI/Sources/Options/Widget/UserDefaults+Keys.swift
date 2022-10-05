import Foundation

extension UserDefaults {
    public static var widget: UserDefaults? {
        .init(suiteName: .appGroup)
    }

    public var keys: [WidgetKey] {
        get {
            (try? JSONDecoder().decode([WidgetKey].self, from: widgetKeysData))
            ?? []
        }
        set {
            widgetKeysData = (try? JSONEncoder().encode(newValue)) ?? .init()
            synchronize()
        }
    }

    @objc dynamic var widgetKeysData: Data {
        get {
            data(forKey: "widgetKeysData") ?? .init()
        }
        set {
            setValue(newValue, forKey: "widgetKeysData")
        }
    }
}
