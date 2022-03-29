import Foundation
import Logging

class JSONStorage<T: Codable> {
    private let logger = Logger(label: "jsonstorage")

    let filename: String

    init<T>(for type: T.Type, filename: String) {
        self.filename = filename.appending(".json")
    }

    func read() -> T? {
        do {
            let location = try getDataLocation()
            guard location.isExists else { return nil }
            let data = try Data(contentsOf: location)
            return try JSONDecoder().decode(T.self, from: data)
        } catch {
            logger.critical("read error: \(error)")
            return nil
        }
    }

    func write(_ objects: T) {
        do {
            let data = try JSONEncoder().encode(objects)
            try data.write(to: getDataLocation())
        } catch {
            logger.critical("write error: \(error)")
        }
    }

    func delete() {
        do {
            let location = try getDataLocation()
            guard location.isExists else { return }
            try FileManager.default.removeItem(at: location)
        } catch {
            logger.critical("delete error: \(error)")
        }
    }

    func getDataLocation() throws -> URL {
        let paths = FileManager.default.urls(
            for: .applicationSupportDirectory,
            in: .userDomainMask)
        let directory = paths[0]
        if !directory.isExists {
            try FileManager.default.createDirectory(
                at: directory,
                withIntermediateDirectories: true)
        }
        return paths[0].appendingPathComponent(filename)
    }
}
