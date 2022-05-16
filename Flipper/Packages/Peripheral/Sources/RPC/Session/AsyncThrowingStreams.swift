public struct AsyncThrowingStreams {
    typealias Output = AsyncThrowingStream<Content, Swift.Error>
    typealias Input = AsyncThrowingStream<Response, Swift.Error>

    let output: AsyncThrowingStream<Content, Swift.Error>
    let input: AsyncThrowingStream<Response, Swift.Error>

    // swiftlint:disable implicitly_unwrapped_optional
    init(builder: (Output.Continuation, Input.Continuation) -> Void) {
        var outputContinuation: Output.Continuation!
        var inputContinuation: Input.Continuation!
        self.output = .init {
            outputContinuation = $0
        }
        self.input = .init {
            inputContinuation = $0
        }
        builder(outputContinuation, inputContinuation)
    }
}
