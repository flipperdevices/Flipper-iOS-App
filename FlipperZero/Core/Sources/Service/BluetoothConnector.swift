//
//  BluetoothConnector.swift
//  FlipperZero
//
//  Created by Eugene Berdnikov on 8/22/20.
//

protocol BluetoothConnector {
    var peripherals: SafePublisher<[Peripheral]> { get }
    var status: SafePublisher<BluetoothStatus> { get }

    func startScanForPeripherals()
    func stopScanForPeripherals()
}
