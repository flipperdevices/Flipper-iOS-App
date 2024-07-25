import Foundation

public class WebInfraredService: InfraredService {
    let baseURL: URL

    public init(baseURL: URL) {
        self.baseURL = baseURL
    }

    public func categories() async throws -> InfraredCategories {
        return try await CategoriesRequest(baseURL: baseURL).get()
    }

    public func brands(
        forCategoryID: Int
    ) async throws -> InfraredBrands {
        return try await BrandsRequest(
            baseURL: baseURL,
            categoryId: forCategoryID
        ).get()
    }

    public func signal(
        forBrandID: Int,
        forCategoryID: Int,
        successResults: [Int],
        failedResults: [Int]
    ) async throws -> InfraredSignal {
        return try await SignalRequest(
            baseURL: baseURL,
            brandId: forBrandID,
            categoryId: forCategoryID,
            successResults: successResults,
            failedResults: failedResults
        ).get()
    }

    public func content(
        forIfrID: Int
    ) async throws -> InfraredKeyContent {
        return try await ContentRequest(
            baseURL: baseURL,
            ifrId: forIfrID
        ).get()
    }

    public func layout(
        forIfrID: Int
    ) async throws -> InfraredLayout {
        return try await LayoutRequest(
            baseURL: baseURL,
            ifrId: forIfrID
        ).get()
    }
}
