import Combine

public typealias DisposeBag = [AnyCancellable]
public typealias SafePublisher<Output> = AnyPublisher<Output, Never>
public typealias SafeSubject<Output> = CurrentValueSubject<Output, Never>
