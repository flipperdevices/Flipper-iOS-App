//
//  CombineExtensions.swift
//  FlipperZero
//
//  Created by Eugene Berdnikov on 8/22/20.
//

import Combine

typealias DisposeBag = [AnyCancellable]
typealias SafePublisher<Output> = AnyPublisher<Output, Never>
typealias SafeSubject<Output> = CurrentValueSubject<Output, Never>
