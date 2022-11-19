//
//  View.swift
//  
//
//  Created by Ilya Chirkov on 14.10.2022.
//

import SwiftUI

extension View {
    @available(iOS, deprecated: 15.0, message: "This extension is no longer necessary. Use API built into SDK")
    func task(
        priority: TaskPriority = .userInitiated,
        _ action: @escaping @Sendable () async -> Void
    ) -> some View {
        self.onAppear {
            Task(priority: priority) {
                await action()
            }
        }
    }
    
    @ViewBuilder func submitLabelDoneIfAvailable() -> some View {
        if #available(iOS 15, *) {
            submitLabel(.done)
        } else {
            self
        }
    }
    
    @ViewBuilder func enableTextSelectionIfAvailable() -> some View {
        if #available(iOS 15, *) {
            textSelection(.enabled)
        } else {
            self
        }
    }
}

extension EnvironmentValues {
    var dismiss: () -> Void {
        { presentationMode.wrappedValue.dismiss() }
    }
}
