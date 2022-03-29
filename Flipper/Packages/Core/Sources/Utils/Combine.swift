import Combine

public typealias DisposeBag = [AnyCancellable]
public typealias SafePublisher<Output> = AnyPublisher<Output, Never>
public typealias SafeValueSubject<Output> = CurrentValueSubject<Output, Never>
public typealias SafeSubject<Output> = PassthroughSubject<Output, Never>
