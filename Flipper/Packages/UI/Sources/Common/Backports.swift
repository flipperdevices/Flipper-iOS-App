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
    
    @ViewBuilder func submitLabelReturnIfAvailable() -> some View {
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
    
    @ViewBuilder func backgroundIfAvailable<S>(_ style: S, ignoresSafeAreaEdges edges: Edge.Set = .all) -> some View where S : ShapeStyle {
        if #available(iOS 15, *) {
            background(style, ignoresSafeAreaEdges: edges)
        } else {
            self
        }
    }
    
    @ViewBuilder func tintA1IfAvailable() -> some View {
        if #available(iOS 15, *) {
            tint(.a1)
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

extension View {
    public func alertBackport(isPresented: Binding<Bool>, content: () -> Alert) -> some View {
        self.overlay(
            EmptyView().alert(isPresented: isPresented, content: content),
            alignment: .bottomTrailing
        )
    }
}

struct A1ToggleStyle: ToggleStyle {
    func makeBody(configuration: Configuration) -> some View {
        Button(action: { configuration.isOn.toggle() }) {
            HStack {
                configuration.label
                Spacer()
                Image(systemName: configuration.isOn ? "checkmark.square.fill" : "square")
                    .foregroundColor(.a1)
            }
        }
    }
}

struct BackgroundModifier: ViewModifier {
    let color: Color
    
    func body(content: Content) -> some View {
        content
            .padding(2)
            .background(color)
            .cornerRadius(4)
    }
}
