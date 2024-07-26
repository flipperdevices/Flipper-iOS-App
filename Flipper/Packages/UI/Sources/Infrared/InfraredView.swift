import Core
import SwiftUI

struct InfraredView: View {

    enum Destination: Hashable {
        case infraredChooseBrand(InfraredCategory)
        case infraredChooseSignal(InfraredBrand)
    }

    var body: some View {
        InfraredChooseCategory()
            .navigationDestination(for: Destination.self) { destination in
                switch destination {
                case .infraredChooseBrand(let category):
                    InfraredChooseBrand(category: category)
                case .infraredChooseSignal(let brand):
                    InfraredChooseSignal(brand: brand)
                }
            }
    }
}
