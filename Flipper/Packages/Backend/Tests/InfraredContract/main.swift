import Foundation
import Infrared

struct InfraredContractTest {
    static let service = WebInfraredService(
        baseURL: URL(string: "https://infrared.flipperzero.one")!
    )

    static func run() async throws {
        // Categories
        try await testCategoriesRequest()

        // Brands
        try await testBrandsRequest()
        try await testBrandsNotExistRequest()

        // Content
        try await testСontentRequest()
        try await testСontentNotExistRequest()

        // Layout
        try await testLayoutRequest()
        try await testLayoutNotExistRequest()

        // Signal
        try await testSignalEmptyRequest()
        try await testSignalWithResultRequest()
    }

    static func testCategoriesRequest() async throws {
        let response = try await service.categories().get()
        assert(!response.categories.isEmpty)
    }

    static func testBrandsRequest() async throws {
        let response = try await service.brands(forCategoryID: 1).get()
        assert(!response.brands.isEmpty)
    }

    static func testBrandsNotExistRequest() async throws {
        let response = try await service.brands(forCategoryID: -1).get()
        assert(response.brands.isEmpty)
    }

    static func testСontentRequest() async throws {
        let _ = try await service.content(forIfrID: 1).get()
    }

    static func testСontentNotExistRequest() async throws {
        do {
            let _ = try await service.content(forIfrID: -1).get()
            assert(false)
        } catch {}
    }

    static func testLayoutRequest() async throws {
        let _ = try await service.layout(forIfrID: 1).get()
    }

    static func testLayoutNotExistRequest() async throws {
        do {
            let _ = try await service.layout(forIfrID: -1).get()
            assert(false)
        } catch {}
    }

    static func testSignalEmptyRequest() async throws {
        do {
            let _ = try await service
                .signal(forBrandID: 1, forCategoryID: 1)
                .get()
            assert(false) // Wait for fix response body
        } catch {}
    }

    static func testSignalWithResultRequest() async throws {
        do {
            let _ = try await service
                .signal(forBrandID: 1, forCategoryID: 1)
                .filter(failedResults: [1], successResults: [2])
                .get()
            assert(false) // Wait for fix response body
        } catch {}
    }

}

try await InfraredContractTest.run()
