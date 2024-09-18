public protocol InfraredService {
    func categories() async throws -> InfraredCategories
    func brands(forCategoryID: Int) async throws -> InfraredBrands
    func signal(
        forBrandID: Int,
        forCategoryID: Int,
        successSignals: [Int],
        failedSignals: [Int],
        skippedSignals: [Int]
    ) async throws -> InfraredSelection
    func content(forIfrID: Int) async throws -> InfraredKeyContent
    func layout(forIfrID: Int) async throws -> InfraredLayout
    func brandFiles(forBrandID: Int) async throws -> InfraredBrandFiles
}
