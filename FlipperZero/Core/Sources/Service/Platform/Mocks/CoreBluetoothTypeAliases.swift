/*
* Copyright (c) 2020, Nordic Semiconductor
* All rights reserved.
*
* Redistribution and use in source and binary forms, with or without modification,
* are permitted provided that the following conditions are met:
*
* 1. Redistributions of source code must retain the above copyright notice, this
*    list of conditions and the following disclaimer.
*
* 2. Redistributions in binary form must reproduce the above copyright notice, this
*    list of conditions and the following disclaimer in the documentation and/or
*    other materials provided with the distribution.
*
* 3. Neither the name of the copyright holder nor the names of its contributors may
*    be used to endorse or promote products derived from this software without
*    specific prior written permission.
*
* THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
* ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
* WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.
* IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT,
* INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT
* NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
* PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,
* WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
* ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
* POSSIBILITY OF SUCH DAMAGE.
*/

import CoreBluetoothMock

// Copy this file to your project to start using CoreBluetoothMock classes
// without having to refactor any of your code. You will just have to remove
// the imports to CoreBluetooth to fix conflicts and initiate the manager
// using CBCentralManagerFactory, instad of just creating a CBCentralManager.

// disabled for Xcode 12.5 beta
typealias CBCentralManagerFactory         = CBMCentralManagerFactory
typealias CBUUID                          = CBMUUID
typealias CBError                         = CBMError
typealias CBATTError                      = CBMATTError
typealias CBManagerState                  = CBMManagerState
typealias CBPeripheralState               = CBMPeripheralState
typealias CBCentralManager                = CBMCentralManager
typealias CBCentralManagerDelegate        = CBMCentralManagerDelegate
typealias CBPeripheral                    = CBMPeripheral
typealias CBPeripheralDelegate            = CBMPeripheralDelegate
typealias CBService                       = CBMService
typealias CBCharacteristic                = CBMCharacteristic
typealias CBCharacteristicWriteType       = CBMCharacteristicWriteType
typealias CBCharacteristicProperties      = CBMCharacteristicProperties
typealias CBDescriptor                    = CBMDescriptor
typealias CBConnectionEvent               = CBMConnectionEvent
typealias CBConnectionEventMatchingOption = CBMConnectionEventMatchingOption
@available(iOS 11.0, tvOS 11.0, watchOS 4.0, *)
typealias CBL2CAPPSM                      = CBML2CAPPSM
@available(iOS 11.0, tvOS 11.0, watchOS 4.0, *)
typealias CBL2CAPChannel                  = CBML2CAPChannel

let CBCentralManagerScanOptionAllowDuplicatesKey       = CBMCentralManagerScanOptionAllowDuplicatesKey
let CBCentralManagerOptionShowPowerAlertKey            = CBMCentralManagerOptionShowPowerAlertKey
let CBCentralManagerOptionRestoreIdentifierKey         = CBMCentralManagerOptionRestoreIdentifierKey
let CBCentralManagerScanOptionSolicitedServiceUUIDsKey = CBMCentralManagerScanOptionSolicitedServiceUUIDsKey
let CBConnectPeripheralOptionStartDelayKey             = CBMConnectPeripheralOptionStartDelayKey
#if !os(macOS)
@available(iOS 13.0, tvOS 13.0, watchOS 6.0, *)
let CBConnectPeripheralOptionRequiresANCS              = CBMConnectPeripheralOptionRequiresANCS
#endif
let CBCentralManagerRestoredStatePeripheralsKey        = CBMCentralManagerRestoredStatePeripheralsKey
let CBCentralManagerRestoredStateScanServicesKey       = CBMCentralManagerRestoredStateScanServicesKey
let CBCentralManagerRestoredStateScanOptionsKey        = CBMCentralManagerRestoredStateScanOptionsKey

let CBAdvertisementDataLocalNameKey                    = CBMAdvertisementDataLocalNameKey
let CBAdvertisementDataServiceUUIDsKey                 = CBMAdvertisementDataServiceUUIDsKey
let CBAdvertisementDataIsConnectable                   = CBMAdvertisementDataIsConnectable
let CBAdvertisementDataTxPowerLevelKey                 = CBMAdvertisementDataTxPowerLevelKey
let CBAdvertisementDataServiceDataKey                  = CBMAdvertisementDataServiceDataKey
let CBAdvertisementDataManufacturerDataKey             = CBMAdvertisementDataManufacturerDataKey
let CBAdvertisementDataOverflowServiceUUIDsKey         = CBMAdvertisementDataOverflowServiceUUIDsKey
let CBAdvertisementDataSolicitedServiceUUIDsKey        = CBMAdvertisementDataSolicitedServiceUUIDsKey

let CBConnectPeripheralOptionNotifyOnConnectionKey     = CBMConnectPeripheralOptionNotifyOnConnectionKey
let CBConnectPeripheralOptionNotifyOnDisconnectionKey  = CBMConnectPeripheralOptionNotifyOnDisconnectionKey
let CBConnectPeripheralOptionNotifyOnNotificationKey   = CBMConnectPeripheralOptionNotifyOnNotificationKey
