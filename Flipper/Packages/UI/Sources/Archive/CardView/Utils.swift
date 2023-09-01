import Core
import SwiftUI

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
