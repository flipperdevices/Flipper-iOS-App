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
        successSignals: [Int],
        failedSignals: [Int]
    ) async throws -> InfraredSelection {
        return try await SignalRequest(
            baseURL: baseURL,
            brandId: forBrandID,
            categoryId: forCategoryID,
            successSignals: successSignals,
            failedSignals: failedSignals
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

    public func brandFiles(
        forBrandID: Int
    ) async throws -> InfraredBrandFiles {
        return try await BrandFilesRequest(
            baseURL: baseURL,
            brandId: forBrandID
        ).get()
    }
}
