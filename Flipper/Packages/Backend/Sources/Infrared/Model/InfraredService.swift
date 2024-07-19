public protocol InfraredService {
    func categories() -> CategoriesRequest
    func brands(forCategoryID: Int) -> BrandsRequest
    func signal(forBrandID: Int, forCategoryID: Int) -> SignalRequest
    func content(forIfrID: Int) -> ContentRequest
    func layout(forIfrID: Int) -> LayoutRequest
}
