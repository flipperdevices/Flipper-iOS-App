class DelimitedResponse {
    var partialResponse: Response?

    func feed(_ main: PB_Main) throws -> Result<Response, Error>? {
        defer { resetIfNeeded(inspecting: main) }

        guard main.commandStatus == .ok else {
            return .failure(.init(main.commandStatus))
        }

        guard case let .some(content) = main.content else {
            return .some(.success(.ok))
        }

        let response = Response(decoding: content)

        do {
            switch (main.hasNext_p, partialResponse) {

            case (false, .none):
                return .success(response)

            case (true, .none):
                partialResponse = response
                return nil

            case (false, .some(let current)):
                return .success(try current.merging(with: response))

            case (true, .some(let current)):
                partialResponse = try current.merging(with: response)
                return nil
            }
        } catch {
            return .failure(.unexpectedResponse(response))
        }
    }

    func resetIfNeeded(inspecting main: PB_Main) {
        var reset = false

        // all cases in one place not to
        // forget resetting partialResponse
        reset = reset || main.hasNext_p == false
        reset = reset || main.commandStatus != .ok
        reset = reset || main.content == nil

        if reset {
            partialResponse = nil
        }
    }
}
