import Backend
import Foundation

public struct SignalRequest: BackendRequest {
    public typealias Result = InfraredSelection

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
        failedSignals: [Int],
        skippedSignals: [Int]
    ) {
        self.baseURL = baseURL
        self.progress = DetectionProgress(
            brandId: brandId,
            categoryId: categoryId,
            failedSignals: failedSignals,
            successSignals: successSignals,
            skippedSignals: skippedSignals
        )
    }
}

extension SignalRequest {
    struct DetectionProgress: Encodable {
        let brandId: Int
        let categoryId: Int
        let failedSignals: [InfraredSignalReguest]
        let successSignals: [InfraredSignalReguest]
        let skippedSignals: [InfraredSignalReguest]

        enum CodingKeys: String, CodingKey {
            case brandId = "brand_id"
            case categoryId = "category_id"
            case failedSignals = "failed_results"
            case successSignals = "success_results"
            case skippedSignals = "skipped_results"
        }

        init(
            brandId: Int,
            categoryId: Int,
            failedSignals: [Int],
            successSignals: [Int],
            skippedSignals: [Int]
        ) {
            self.brandId = brandId
            self.categoryId = categoryId
            self.failedSignals = failedSignals.map { .init(signalId: $0) }
            self.successSignals = successSignals.map { .init(signalId: $0) }
            self.skippedSignals = skippedSignals.map { .init(signalId: $0) }
        }
    }

    struct InfraredSignalReguest: Encodable {
        let signalId: Int

        enum CodingKeys: String, CodingKey {
            case signalId = "signal_id"
        }
    }
}
