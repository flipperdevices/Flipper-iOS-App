import Foundation

class FlipperSession: Session {
    var request: Request?
    var continuation: ((Response) -> Void)?

    let chunkedResponse: ChunkedResponse = .init()
    let sequencedResponse: SequencedResponse = .init()

    let sequencedRequest: SequencedRequest = .init()
    let chunkedRequest: ChunkedRequest = .init()

    func sendRequest(
        _ request: Request,
        continuation: @escaping Session.Continuation,
        consumer: (Data) -> Void
    ) {
        self.request = request
        self.continuation = continuation

        let requests = sequencedRequest.split(request)
        for request in requests {
            let chunks = chunkedRequest.split(request)
            for chunk in chunks {
                assert(!chunk.isEmpty)
                consumer(.init(chunk))
            }
        }
    }

    func didReceiveData(_ data: Data) {
        do {
            // single PB_Main can be split into ble chunks;
            // returns nil if data.count < main.size
            guard let nextResponse = try chunkedResponse.feed(data) else {
                return
            }
            // complete PB_Main can be split into multiple messages
            guard let response = try sequencedResponse.feed(nextResponse) else {
                return
            }
            // TODO: Compare message id
            if case .error(let error) = response {
                print(error)
            }
            guard let continuation = self.continuation else {
                print("unexpected response", response)
                return
            }
            self.request = nil
            self.continuation = nil
            continuation(response)
        } catch {
            print(error)
        }
    }
}
