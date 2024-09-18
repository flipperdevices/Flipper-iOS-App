import Core
import SwiftUI

typealias InfraredSignals = [InfraredSignal: InfraredChooseSignalType]

struct InfraredView: View {

    enum Destination: Hashable {
        case chooseBrand(InfraredCategory)
        case chooseSignal(InfraredBrand, InfraredSignals)
        case layout(InfraredFile)
        case save(InfraredFile, ArchiveItem)
    }

    var body: some View {
        InfraredChooseCategory()
            .navigationDestination(for: Destination.self) { destination in
                switch destination {
                case .chooseBrand(let category):
                    InfraredChooseBrand(category: category)
                case .chooseSignal(let brand, let signals):
                    InfraredChooseSignal(brand: brand, signals: signals)
                case .layout(let file):
                   InfraredPagesLayout(file: file)
                case .save(let file, let item):
                    InfraredSaveRemote(file: file, item: item)
                }
            }
    }
}
