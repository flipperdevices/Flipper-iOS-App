//
//  BluetoothStatus.swift
//  FlipperZero
//
//  Created by Eugene Berdnikov on 8/22/20.
//

enum BluetoothStatus: Equatable {
    enum NotReadyReason: String {
        case poweredOff
        case preparing
        case unauthorized
        case unsupported
    }

    case ready
    case notReady(NotReadyReason)
}
