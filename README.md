# Flipper-iOS-App

This is a work-in-progress iOS/watchOS/iPadOS app to rule all the Flipper family.

The app is being written in SwiftUI for iOS/iPadOS 14, watchOS 7 and macOS 11.

## Development status

### A rough roadmap

#### Stage 0

1. Bluetooth connections setup. 
2. Basic data exchange with extensible support of different data types (dumps, plugins, settings, whatever).
3. Some simple interface for testing.
4. Shortcuts integration.

#### Stage 1

1. Plugins store.
2. Flipper basic features support.
3. Some App Store worthy interface work. Basic iPadOS support.

#### Stage 2

1. Advanced platform features, such as iCloud sync, AirDrop, file browser, widgets etc.
2. Keyboard&mouse support, iPadOS and macOS interface.
3. watchOS.

### How to contribute

#### Current status 

Now we're at **stage 0**.

#### First priority tasks

##### Bluetooth

Make BLE interaction work. The challenge here is we don't have any hardware on hand. Protocol is probably protobuf (discussion is ongoing).

##### Shortcuts support

Since Flipper is meant for hackers, users should be able to create interfaces for their Flipper firmware plugins. 

Seems like Shortcuts fit this task, since they don't require App Store review and can be distributed easily. We'll probably need to make an API—a set of Shortcut actions. Community-created shortcuts could leverage this API to exchange messages between their iDevices and Flipper.