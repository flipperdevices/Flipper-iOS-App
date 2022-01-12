import Core
import SwiftUI

// swiftlint:disable opening_brace

extension Binding where
    Value: MutableCollection,
    Value: RangeReplaceableCollection,
    Value.Index == Int
{
    subscript(safe index: Value.Index) -> Binding<Value.Element> {
        Binding<Value.Element> {
            self.wrappedValue[index]
        } set: {
            self.wrappedValue[index] = $0
        }
    }
}

extension ArchiveItem {
    subscript(key: String) -> String? {
        properties.first { $0.key == key }?.value
    }
}
