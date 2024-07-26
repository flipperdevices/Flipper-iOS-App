import Backend
import Foundation

public struct SignalRequest: BackendRequest {
    public typealias Result = InfraredSignal

    public var path: String { "signal" }
    public var queryItems: [URLQueryItem] = []

    public var method: String? { "POST" }
    public var body: Encodable? { progress }

    public let baseURL: URL
    private let progress: DetectionProgress

    public init(
        baseURL: URL,
        brandId: Int,
        categoryId: Int,
        successSignals: [Int],
        failedSignals: [Int]
    ) {
        self.baseURL = baseURL
        self.progress = DetectionProgress(
            brandId: brandId,
            categoryId: categoryId,
            failedSignals: failedSignals,
            successSignals: successSignals
        )
    }
}

extension SignalRequest {
    struct DetectionProgress: Encodable {
        let brandId: Int
        let categoryId: Int
        let failedSignals: [InfraredSignalReguest]
        let successSignals: [InfraredSignalReguest]

        enum CodingKeys: String, CodingKey {
            case brandId = "brand_id"
            case categoryId = "category_id"
            case failedSignals = "failed_results"
            case successSignals = "success_results"
        }

        init(
            brandId: Int,
            categoryId: Int,
            failedSignals: [Int],
            successSignals: [Int]
        ) {
            self.brandId = brandId
            self.categoryId = categoryId
            self.failedSignals = failedSignals.map { .init(signalId: $0) }
            self.successSignals = successSignals.map { .init(signalId: $0) }
        }
    }

    // MARK: Remove after fix model
    struct InfraredSignalReguest: Encodable {
        let signalId: Int
        let ifrFileId: Int

        init(signalId: Int) {
            self.signalId = signalId
            self.ifrFileId = 0
        }

        enum CodingKeys: String, CodingKey {
            case signalId = "signal_id"
            case ifrFileId = "ifr_file_id"
        }
    }
}
