import Combine

typealias DisposeBag = [AnyCancellable]
typealias SafePublisher<Output> = AnyPublisher<Output, Never>
typealias SafeSubject<Output> = CurrentValueSubject<Output, Never>
