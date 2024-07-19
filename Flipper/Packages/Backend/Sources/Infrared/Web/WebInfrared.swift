import Foundation

public class WebInfraredService: InfraredService {
    public let baseURL: URL

    public init(baseURL: URL) {
        self.baseURL = baseURL
    }

    public func categories() -> CategoriesRequest {
        .init(baseURL: baseURL)
    }

    public func brands(forCategoryID: Int) -> BrandsRequest {
        .init(baseURL: baseURL, categoryId: forCategoryID)
    }

    public func signal(forBrandID: Int, forCategoryID: Int) -> SignalRequest {
        .init(
            baseURL: baseURL,
            brandId: forBrandID,
            categoryId: forCategoryID)
    }

    public func content(forIfrID: Int) -> ContentRequest {
        .init(baseURL: baseURL, ifrId: forIfrID)
    }

    public func layout(forIfrID: Int) -> LayoutRequest {
        .init(baseURL: baseURL, ifrId: forIfrID)
    }
}
