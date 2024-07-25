import Infrared

import Combine
import Foundation

@MainActor
public class InfraredModel: ObservableObject {
    private let service: InfraredService

    @Published public var categories: [InfraredCategory] = []
    @Published public var brands: [Int: [InfraredBrand]] = [:]

    public init(service: InfraredService) {
        self.service = service
    }

    private var categoriesTask: Task<[InfraredCategory], Swift.Error>?

    public func loadCategories() async {
        do {
            if let task = categoriesTask {
                categories = try await task.value
            } else {
                let task = Task<[InfraredCategory], Swift.Error> {
                    try await service
                        .categories()
                        .categories
                        .map { .init(category: $0) }
                }

                categoriesTask = task
                categories = try await task.value
                categoriesTask = nil
            }
        } catch {
            logger.error("load category \(error)")
        }
    }

    private var brandTasks: [Int: Task<[InfraredBrand], Swift.Error>] = [:]

    public func loadBrand(forCategoryID: Int) async {
        do {
            if let task = brandTasks[forCategoryID] {
                brands[forCategoryID] = try await task.value
            } else {
                let task = Task<[InfraredBrand], Swift.Error> {
                    try await service
                        .brands(forCategoryID: forCategoryID)
                        .brands
                        .map { .init($0, forCategoryID) }
                }

                brandTasks[forCategoryID] = task
                brands[forCategoryID] = try await task.value
                brandTasks[forCategoryID] = nil
            }
        } catch {
            logger.error("load brand \(forCategoryID) \(error)")
        }
    }

    public func loadSignal(
        brand: InfraredBrand,
        successControls: [Int],
        failureControls: [Int]
    ) async throws -> InfraredSignal {
        let response = try await service
            .signal(
                forBrandID: brand.id,
                forCategoryID: brand.categoryID,
                successResults: successControls,
                failedResults: failureControls
           )
        return InfraredSignal(response)
    }

    public func loadContent(irFileId: Int) async throws -> String {
        try await service.content(forIfrID: irFileId).content
    }
}
