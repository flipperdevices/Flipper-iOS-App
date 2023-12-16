import Darwin

public class AppReset {
    public static func reset() async {
        do {
            UserDefaultsStorage.shared.reset()
            try await FileStorage().reset()
            exit(0)
        } catch {
            logger.error("\(error)")
        }
    }
}
