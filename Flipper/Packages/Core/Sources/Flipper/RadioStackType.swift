public enum RadioStackType: String, CustomStringConvertible {
    case bleFull = "1"
    case bleLight = "3"
    case bleBeacon = "4"
    case bleBasic = "5"
    case bleFullExtAdv = "6"
    case bleHCIExtAdv = "7"

    public var description: String {
        switch self {
        case .bleFull: return "Full"
        case .bleLight: return "Light"
        case .bleBeacon: return "Beacon"
        case .bleBasic: return "Basic"
        case .bleFullExtAdv: return "Full Ext Adv"
        case .bleHCIExtAdv: return "HCI Ext Adv"
        }
    }
}
