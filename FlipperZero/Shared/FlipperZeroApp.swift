//
//  FlipperZeroApp.swift
//  FlipperZero
//
//  Created by Yakov Shapovalov on 21.08.2020.
//

import Core
import SwiftUI

@main
struct FlipperZeroApp: App {
    init() {
        Core.registerDependencies()
    }

    var body: some Scene {
        WindowGroup {
            RootView()
        }
    }
}
