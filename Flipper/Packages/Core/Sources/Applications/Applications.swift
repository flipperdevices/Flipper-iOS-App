import Logging
import Catalog

import Foundation

@MainActor
public class Applications: ObservableObject {
    @Published public private(set) var state: State = .loading

    @Published public private(set) var topApp: Application?
    @Published public private(set) var categories: [Category] = []
    @Published public private(set) var applications: [Application] = []
    @Published public var sortOrder: SortOrder = .newUpdates {
        didSet {
            Task {
                await reloadApplications()
            }
        }
    }

    //@Published public var showSearchView = false

    public enum SortOrder: String, CaseIterable {
        case newUpdates = "New Updates"
        case newReleases = "New Releases"
        case oldUpdates = "Old Updates"
        case oldReleases = "Old Releases"
    }

    let catalog: CatalogService

    public enum State {
        case loading
        case ready
        case error(Error)
    }

    public enum Error: Swift.Error {
        case noInternet
    }

    public init(catalog: CatalogService) {
        self.catalog = catalog
    }

    private func demoDelay() async {
        try? await Task.sleep(seconds: 1)
    }

    var categoriesTask: Task<Void, Swift.Error>?
    var applicationsTask: Task<Void, Swift.Error>?

    public func load() {
        if categories.isEmpty {
            reload()
        }
    }

    public func reload() {
        Task {
            state = .loading
            await reloadCategories()
            await reloadApplications()
            state = .ready
        }
    }

    public func reloadCategories() async {
        guard categoriesTask == nil else {
            return
        }
        categoriesTask = Task { @MainActor in
            //await demoDelay()
            try await handlingWebErrors {
                categories = try await loadCategories()
            }
            categoriesTask = nil
        }
        try? await categoriesTask?.value
    }

    public func reloadApplications() async {
        guard applicationsTask == nil else {
            return
        }
        applicationsTask = Task { @MainActor in
            //await demoDelay()
            try await handlingWebErrors {
                applications = try await loadApplications()
            }
            applicationsTask = nil
        }
        try? await applicationsTask?.value
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
            guard let app = try await catalog.featured().get().first else {
                throw Error.noInternet
            }
            let category = try await catalog.category(app.categoryId).get()
            var application = Application(app)
            application.category = .init(category)
            self.topApp = application
        }
    }

    private func loadCategories() async throws -> [Applications.Category] {
        try await handlingWebErrors {
            let categories = try await catalog.categories().get()
            return categories.map(Applications.Category.init)
        }
    }

    private func loadApplications() async throws -> [Application] {
        try await handlingWebErrors {
            let applications = try await catalog
                .applications()
                .skip(0)
                .sort(by: .init(source: sortOrder))
                .order(.init(source: sortOrder))
                .get()

            return applications.map { source in
                var application = Application(source)
                application.category = category(for: source)
                application.status = status(for: application)
                return application
            }
        }
    }

    private func category(for application: Catalog.Application) -> Category {
        categories.first(where: {
            $0.id == application.categoryId
        }) ?? .unknown
    }

    private func status(for application: Application) -> Application.Status {
        [.notInstalled, .installed, .outdated].randomElement()!
    }

    public func loadMore() {
        // ...
    }

    public func loadApplication(id: String) async throws -> Application {
        let source = try await catalog.application(uid: id).get()
        var application = Application(source)
        print(application)
        application.category = category(for: source)
        application.status = status(for: application)
        return application
    }
}

extension Catalog.SortBy {
    init(source: Applications.SortOrder) {
        switch source {
        case .newUpdates, .oldUpdates: self = .updated
        case .newReleases, .oldReleases: self = .created
        }
    }
}

extension Catalog.SortOrder {
    init(source: Applications.SortOrder) {
        switch source {
        case .newUpdates, .newReleases: self = .asc
        case .oldUpdates, .oldReleases: self = .desc
        }
    }
}
