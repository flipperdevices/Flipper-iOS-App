//
//  ServiceFactory.swift
//  FlipperZero
//
//  Created by Eugene Berdnikov on 9/3/20.
//

import Foundation

protocol ServiceFactory {
    func create() -> Any
}

class SingletonFactory: ServiceFactory {
    private let builder: () -> Any

    init(_ builder: @escaping () -> Any) {
        self.builder = builder
    }

    private lazy var value: Any = {
        self.builder()
    }()

    func create() -> Any {
        self.value
    }
}

class SingleUseFactory: ServiceFactory {
    private let builder: () -> Any

    init(_ builder: @escaping () -> Any) {
        self.builder = builder
    }

    func create() -> Any {
        self.builder()
    }
}
