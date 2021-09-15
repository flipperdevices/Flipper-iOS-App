import Core
import Combine
import Injector
import SwiftUI

public class RootViewModel: ObservableObject {
    let sheetManager: SheetManager = .shared

    var sheet: AnyView?
    @Published var isPresentingSheet = false
    var disposeBag: DisposeBag = .init()

    public init() {
        sheetManager.sheet
            .sink { [weak self] in
                self?.sheet = $0
                self?.isPresentingSheet = true
            }
            .store(in: &disposeBag)
    }
}
