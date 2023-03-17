import Darwin

public class AppReset {
    public static func reset() {
        do {
            UserDefaultsStorage.shared.reset()
            try FileStorage().reset()
            exit(0)
        } catch {
            logger.error("\(error)")
        }
    }
}
