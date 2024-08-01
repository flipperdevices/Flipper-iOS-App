import Infrared

import Combine
import Foundation

@MainActor
public class InfraredModel: ObservableObject {
    private let service: InfraredService

    public init(service: InfraredService) {
        self.service = service
    }

    public func loadCategories() async throws -> [InfraredCategory] {
        do {
            return try await service
                .categories()
                .categories
                .map { .init(category: $0) }
        } catch {
            logger.error("load category \(error)")
            throw error
        }
    }

    public func loadBrand(
        forCategoryID: Int
    ) async throws -> [InfraredBrand] {
        do {
            return try await service
                .brands(forCategoryID: forCategoryID)
                .brands
                .map { .init($0, forCategoryID) }
        } catch {
            logger.error("load brand \(error)")
            throw error
        }
    }

    public func loadSignal(
        brand: InfraredBrand,
        successSignals: [Int],
        failedSignals: [Int]
    ) async throws -> InfraredSignal {
        do {
            let response = try await service
                .signal(
                    forBrandID: brand.id,
                    forCategoryID: brand.categoryID,
                    successSignals: successSignals,
                    failedSignals: failedSignals
               )
            return InfraredSignal(response)
        } catch {
            logger.error("load signal \(error)")
            throw error
        }
    }

    public func loadContent(irFileId: Int) async throws -> String {
        try await service.content(forIfrID: irFileId).content
    }
}
