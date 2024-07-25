import Backend
import Foundation

public struct SignalRequest: BackendRequest {
    public typealias Result = InfraredSignal

    public var path: String { "signal" }
    public var queryItems: [URLQueryItem] = []

    public var method: String? { "POST" }
    public var body: Encodable? { response }

    public let baseURL: URL
    var response: Response

    public init(
        baseURL: URL,
        brandId: Int,
        categoryId: Int,
        successResults: [Int],
        failedResults: [Int]
    ) {
        self.baseURL = baseURL
        self.response = Response(
            brandId: brandId,
            categoryId: categoryId,
            failedResults: failedResults,
            successResults: successResults
        )
    }
}

extension SignalRequest {
    struct Response: Encodable {
        var brandId: Int
        var categoryId: Int
        var failedResults: [InfraredSignalResult]
        var successResults: [InfraredSignalResult]

        enum CodingKeys: String, CodingKey {
            case brandId = "brand_id"
            case categoryId = "category_id"
            case failedResults = "failed_results"
            case successResults = "success_results"
        }

        init(
            brandId: Int,
            categoryId: Int,
            failedResults: [Int],
            successResults: [Int]
        ) {
            self.brandId = brandId
            self.categoryId = categoryId
            self.failedResults = failedResults.map { .init(signalId: $0) }
            self.successResults = successResults.map { .init(signalId: $0) }
        }
    }
}

// MARK: Remove after fix model
struct InfraredSignalResult: Encodable {
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
