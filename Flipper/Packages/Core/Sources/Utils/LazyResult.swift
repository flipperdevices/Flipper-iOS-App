public enum LazyResult<Success, Failure> where Failure: Swift.Error {
    case idle
    case working
    case success(Success)
    case failure(Failure)
}
