import Core
import SwiftUI

struct InfraredView: View {

    enum Destination: Hashable {
        case chooseBrand(InfraredCategory)
        case chooseSignal(InfraredBrand)
    }

    var body: some View {
        InfraredChooseCategory()
            .navigationDestination(for: Destination.self) { destination in
                switch destination {
                case .chooseBrand(let category):
                    InfraredChooseBrand(category: category)
                case .chooseSignal(let brand):
                    InfraredChooseSignal(brand: brand)
                }
            }
    }
}
