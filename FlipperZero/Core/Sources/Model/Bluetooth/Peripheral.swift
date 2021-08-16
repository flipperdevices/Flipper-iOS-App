//
//  Peripheral.swift
//  FlipperZero
//
//  Created by Eugene Berdnikov on 8/22/20.
//

import struct Foundation.UUID

struct Peripheral: EquatableById, Identifiable {
    let id: UUID
    let name: String
}
