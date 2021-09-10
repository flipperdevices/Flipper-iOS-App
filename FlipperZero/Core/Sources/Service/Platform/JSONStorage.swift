import Foundation

class JSONStorage<T: Codable> {
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
            print("JSONStorage read error:", error)
            return nil
        }
    }

    func write(_ objects: T) {
        do {
            let data = try JSONEncoder().encode(objects)
            try data.write(to: getDataLocation())
        } catch {
            print("JSONDeviceStorage write error:", error)
        }
    }

    func delete() {
        do {
            let location = try getDataLocation()
            guard location.isExists else { return }
            try FileManager.default.removeItem(at: location)
        } catch {
            print("JSONDeviceStorage delete error:", error)
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

extension URL {
    var isExists: Bool {
        FileManager.default.fileExists(atPath: path)
    }
}
