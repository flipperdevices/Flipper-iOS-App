//
//  Resolver.swift
//  FlipperZero
//
//  Created by Eugene Berdnikov on 8/23/20.
//

public protocol Resolver {
    func resolve<Service>(_ type: Service.Type) -> Service
}
