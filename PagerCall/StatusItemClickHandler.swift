import AppKit

// NOTE: Since macOS 27, the menu bar is hosted by the system and mouse events are no longer
// delivered to views added to the status item button, so clicks are handled via target/action.
@MainActor
class StatusItemClickHandler: NSObject {
    private let statusItem: NSStatusItem
    private var menu: NSMenu?
    private var menuObservation: NSKeyValueObservation?
    var onLeftClick: (() -> Void)?

    init(statusItem: NSStatusItem) {
        self.statusItem = statusItem
        super.init()

        detachMenu()

        // SwiftUI may set the menu again when MenuBarExtra is updated
        menuObservation = statusItem.observe(\.menu, options: [.new]) { [weak self] _, _ in
            MainActor.assumeIsolated {
                self?.detachMenu()
            }
        }

        if let button = statusItem.button {
            button.target = self
            button.action = #selector(onClick(_:))
            button.sendAction(on: [.leftMouseUp, .rightMouseUp])
        }
    }

    private func detachMenu() {
        if let menu = statusItem.menu {
            self.menu = menu
            statusItem.menu = nil
        }
    }

    @objc private func onClick(_: Any?) {
        let event = NSApp.currentEvent

        if event?.type == .rightMouseUp || event?.modifierFlags.contains(.control) == true {
            showMenu()
        } else {
            onLeftClick?()
        }
    }

    private func showMenu() {
        guard let menu, let button = statusItem.button else { return }
        menu.popUp(positioning: nil, at: NSPoint(x: 0, y: button.bounds.height + 5), in: button)
    }
}
