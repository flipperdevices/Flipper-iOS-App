import SwiftUI

enum OverlayInteraction {
    case fullscreen
    case regions([CGRect])
}

class OverlayController: ObservableObject {
    private final class Entry {
        var view: UIView?
        var interaction: OverlayInteraction

        init(interaction: OverlayInteraction) {
            self.interaction = interaction
        }
    }

    private var overlay: OverlayWindow?
    private var entries: [Entry]

    init() {
        self.overlay = OverlayWindow()
        self.entries = []
    }

    func present<Content: View>(
        interaction: OverlayInteraction = .fullscreen,
        @ViewBuilder content: @escaping () -> Content
    ) {
        guard let overlay else { return }

        let entry = Entry(interaction: interaction)

        let viewController = UIHostingController(
            rootView: content()
                .environmentObject(self)
                .environment(
                    \.updateOverlayInteraction,
                    makeUpdateInteraction(for: entry)
                )
        )
        viewController.view.backgroundColor = .clear

        entry.view = viewController.view
        entries.append(entry)

        if let rootViewController = overlay.rootViewController {
            viewController.view.frame = rootViewController.view.frame
        } else {
            overlay.rootViewController = viewController
            overlay.isUserInteractionEnabled = true
            overlay.isHidden = false
        }

        updateWindowInteraction()
    }

    func dismiss() {
        guard let overlay else { return }

        guard !entries.isEmpty else {
            return
        }

        entries.removeFirst()

        if let first = entries.first?.view {
            guard
                let rootViewController = overlay.rootViewController
            else {
                return
            }
            rootViewController.view.subviews.forEach { view in
                view.removeFromSuperview()
            }
            rootViewController.view.addSubview(first)
        } else {
            overlay.isHidden = true
            overlay.isUserInteractionEnabled = false
            overlay.rootViewController = nil
        }

        updateWindowInteraction()
    }

    private func makeUpdateInteraction(
        for entry: Entry
    ) -> (OverlayInteraction) -> Void {
        // NOTE: weak entry makes late frame reports from a queued
        // overlay update its own entry instead of the visible one
        { [weak self, weak entry] interaction in
            guard let self, let entry else { return }
            entry.interaction = interaction
            self.updateWindowInteraction()
        }
    }

    private func updateWindowInteraction() {
        overlay?.interaction = entries.first?.interaction
    }
}

extension EnvironmentValues {
    @Entry var updateOverlayInteraction:
        (OverlayInteraction) -> Void = { _ in }
}
