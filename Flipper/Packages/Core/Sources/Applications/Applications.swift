import Logging
import Catalog

import Foundation

@MainActor
public class Applications: ObservableObject {
    @Published public private(set) var state: State = .loading

    @Published public private(set) var topApp: Application?
    @Published public private(set) var categories: [Category] = []
    @Published public private(set) var applications: [Application] = []
    @Published public var sortOrder: SortOrder = .uploaded

    //@Published public var showSearchView = false

    public enum SortOrder: String, CaseIterable {
        case uploaded = "Update Date"
        case creaded = "Publish Date"
    }

    let catalog: CatalogService

    public enum State {
        case loading
        case ready
        case error(Error)
    }

    public enum Error {
        case noInternet
    }

    public init(catalog: CatalogService) {
        self.catalog = catalog
    }

    private func demoDelay() async {
        try? await Task.sleep(seconds: 1)
    }

    var taskHandle: Task<Void, Swift.Error>?

    public func load() {
        if categories.isEmpty {
            reload()
        }
    }

    public func reload() {
        guard taskHandle == nil else {
            return
        }
        taskHandle = Task { @MainActor in
            state = .loading
            categories = []
            applications = []

            //await demoDelay()
            try await handlingWebErrors {
                self.categories = try await loadCategories()
                self.applications = try await loadApplications()
            }

            state = .ready
            taskHandle = nil
        }
    }

    public func install(_ application: Application) {
        print("install")
    }

    public func update(_ application: Application) {
        print("update")
    }

    public func delete(_ application: Application) {
        print("delete")
    }

    private func handlingWebErrors<T>(
        _ body: () async throws -> T
    ) async rethrows -> T {
        do {
            return try await body()
        } catch {
            print(error)
            throw error
        }
    }

    public func loadTopApp() async throws {
        try await handlingWebErrors {
            let app = try await catalog.getFeaturedApp()
            let cat = try await catalog.getCategory(app.categoryId)
            var application = Application(app)
            application.category = .init(cat)
            self.topApp = application
        }

    }

    private func loadCategories() async throws -> [Applications.Category] {
        try await handlingWebErrors {
            let categories = try await catalog.getCategories()
            return categories.map(Applications.Category.init)
        }
    }

    private func loadApplications() async throws -> [Application] {
        try await handlingWebErrors {
            let applications = try await catalog.getApplications()
            return applications.map { source in
                var application = Application(source)
                if let category = categories.first(where: {
                    $0.id == source.categoryId
                }) {
                    application.category = category
                }
                application.status = status(for: application)
                return application
            }
        }
    }

    private func status(for application: Application) -> Application.Status {
        [.notInstalled, .installed, .outdated].randomElement()!
    }

    public func loadMore() {
        // ...
    }
}
