import Core
import SwiftUI
import UIKit

struct InfraredListBrand: UIViewControllerRepresentable {
    let brands: [InfraredBrand]
    let onTap: (InfraredBrand) -> Void

    func makeUIViewController(context: Context) -> UITableViewController {
        let tableViewController = UITableViewController(style: .plain)
        tableViewController.tableView.dataSource = context.coordinator
        tableViewController.tableView.delegate = context.coordinator
        tableViewController.tableView.sectionIndexColor = UIColor(Color.black40)
        return tableViewController
    }

    func updateUIViewController(
        _ uiViewController: UITableViewController,
        context: Context
    ) {
        uiViewController.tableView.reloadData()
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(brands: brands, onTap: onTap)
    }
}

extension InfraredListBrand {
    class Coordinator: NSObject, UITableViewDataSource, UITableViewDelegate {
        let brands: [InfraredBrand]
        let onTap: (InfraredBrand) -> Void

        private var groupedBrands: [String: [InfraredBrand]] = [:]
        private var sortedKeys: [String] = []

        init(
            brands: [InfraredBrand],
            onTap: @escaping (InfraredBrand) -> Void
        ) {
            self.brands = brands
            self.onTap = onTap
            super.init()
            groupedBrands = groupBrandsByFirstLetter(brands: brands)
            sortedKeys = groupedBrands.keys.sorted()
        }

        func numberOfSections(in tableView: UITableView) -> Int {
            return sortedKeys.count
        }

        func tableView(
            _ tableView: UITableView,
            numberOfRowsInSection section: Int
        ) -> Int {
            let key = sortedKeys[section]
            return groupedBrands[key]?.count ?? 0
        }

        func tableView(
            _ tableView: UITableView,
            cellForRowAt indexPath: IndexPath
        ) -> UITableViewCell {
            let key = sortedKeys[indexPath.section]
            let section = groupedBrands[key]!
            let brand = section[indexPath.row]
            let cell = UITableViewCell(style: .default, reuseIdentifier: nil)
            cell.textLabel?.text = brand.name
            return cell
        }

        func sectionIndexTitles(for tableView: UITableView) -> [String]? {
            return sortedKeys
        }

        func tableView(
            _ tableView: UITableView,
            titleForHeaderInSection section: Int
        ) -> String? {
            return sortedKeys[section]
        }

        func tableView(
            _ tableView: UITableView,
            didSelectRowAt indexPath: IndexPath
        ) {
            let key = sortedKeys[indexPath.section]
            let section = groupedBrands[key]!
            let brand = section[indexPath.row]
            
            onTap(brand)
            tableView.deselectRow(at: indexPath, animated: true)
        }

        private func groupBrandsByFirstLetter(
            brands: [InfraredBrand]
        ) -> [String: [InfraredBrand]] {
            Dictionary(grouping: brands) { brand in
                String(brand.name.prefix(1).uppercased())
            }
        }
    }
}
