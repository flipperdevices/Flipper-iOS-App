//
//  EquatableById.swift
//  FlipperZero
//
//  Created by Eugene Berdnikov on 8/22/20.
//

protocol EquatableById: Equatable {
}

extension EquatableById where Self: Identifiable {
    static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.id == rhs.id
    }
}
