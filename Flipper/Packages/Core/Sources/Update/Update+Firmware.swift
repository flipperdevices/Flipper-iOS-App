import Peripheral
import Foundation

extension Update {
    public struct Firmware {
        let version: Manifest.Version
        let entries: [Entry]

        public enum Entry {
            case file(File)
            case directory(String)
        }

        public struct File {
            let name: String
            let data: [UInt8]
        }

        var files: [File] {
            entries.compactMap { entry in
                switch entry {
                case let .file(file): return file
                default: return nil
                }
            }
        }
    }
}
