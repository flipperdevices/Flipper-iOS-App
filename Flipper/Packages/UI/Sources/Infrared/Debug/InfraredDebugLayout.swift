import SwiftUI
import Core

struct InfraredDebugLayout: View {
    @EnvironmentObject private var model: InfraredModel

    @State private var brands: [InfraredCategory: [InfraredBrand]] = [:]
    @State private var isLoading: Bool = true

    var body: some View {
        Group {
            if isLoading {
                ProgressView()
            } else {
                List {
                    ForEach(
                        Array(brands.keys).sorted { $0.name > $1.name },
                        id: \.self
                    ) { key in
                        NavigationLink(
                            destination: Brands(brands: brands[key]!)
                        ) {
                            Text(key.name)
                        }
                    }
                }
            }
        }
        .task {
            isLoading = true
            defer { isLoading = false }

            guard brands.isEmpty else { return }
            do {
                try await model
                    .loadCategories()
                    .forEach { category in
                        brands[category] = try await model.loadBrand(category)
                }
            } catch {
                print("infared debug \(error)")
            }
        }
    }
}

extension InfraredDebugLayout {
    struct Brands: View {
        let brands: [InfraredBrand]

        var body: some View {
            List {
                ForEach(brands) { value in
                    NavigationLink(destination: BrandLayouts(brand: value)) {
                        Text(value.name)
                    }
                }
            }
        }
    }

    struct BrandLayouts: View {
        @EnvironmentObject private var model: InfraredModel

        @State private var isLoading: Bool = true
        @State private var layouts: [InfraredFile: InfraredLayout] = [:]

        @State private var layoutState: InfraredLayoutState = .default

        private let states: [InfraredLayoutState] = [
            .default,
            .disabled,
            .emulating,
            .syncing
        ]

        let brand: InfraredBrand

        var body: some View {
            Group {
                if isLoading {
                    ProgressView()
                } else {
                    VStack {
                        Picker("State", selection: $layoutState) {
                            ForEach(states, id: \.self) { state in
                                Text(state.rawValue.capitalized)
                            }
                        }
                        .pickerStyle(.segmented)
                        .padding()

                        ScrollView(.horizontal) {
                            LazyHStack(alignment: .center, spacing: 0) {
                                ForEach(Array(layouts.keys), id: \.self) {
                                    Layout(
                                        file: $0,
                                        layout: layouts[$0]!
                                    )
                                    .environment(\.layoutState, layoutState)
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle(brand.name)
            .task {
                isLoading = true
                defer { isLoading = false }

                guard layouts.isEmpty else { return }
                do {
                    try await model.loadInfraredFiles(brand).forEach { file in
                        layouts[file] = try await model.loadLayout(file)
                    }
                } catch {
                    print("infared debug \(error)")
                }
            }
        }
    }

    struct Layout: View {
        let file: InfraredFile
        let layout: InfraredLayout

        var body: some View {
            VStack {
                Text("File: '\(file.id)'")
                    .font(.system(size: 14, weight: .medium))

                InfraredLayoutPagesView(layout: layout)
                    .frame(width: UIScreen.main.bounds.width)
                    .frame(maxHeight: .infinity)
            }
        }
    }
}
