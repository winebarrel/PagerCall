import AsyncAlgorithms
import MenuBarExtraAccess
import SwiftUI

@main
struct PagerCallApp: App {
    @State private var initialized = false
    @State private var isMenuPresented = false
    @State private var timer: Task<Void, Never>?
    // NOTE: Define "apiKey" in PagerCallApp so that values are not lost during sleep.
    @State private var apiKey = Vault.apiKey
    @AppStorage("interval") private var interval = Constants.defaultInterval
    @StateObject private var pagerDuty = PagerDutyModel()

    // swiftlint:disable unused_declaration
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    // swiftlint:enable unused_declaration

    private var popover: NSPopover = {
        let pop = NSPopover()
        pop.behavior = .transient
        pop.animates = false
        pop.contentSize = NSSize(width: 500, height: 400)
        return pop
    }()

    private func initialize() {
        let contentView = ContentView(pagerDuty: pagerDuty, apiKey: $apiKey)
        popover.contentViewController = NSHostingController(rootView: contentView)

        scheduleUpdate()
    }

    private func scheduleUpdate() {
        timer?.cancel()

        let seq = AsyncTimerSequence(
            interval: .seconds(interval),
            clock: .continuous
        )

        timer = Task {
            await pagerDuty.update(apiKey)

            for await _ in seq {
                await pagerDuty.update(apiKey)
            }
        }
    }

    var body: some Scene {
        MenuBarExtra {
            RightClickMenu()
        } label: {
            Image(systemName: self.pagerDuty.status.rawValue)
            Text("PD")
        }.menuBarExtraAccess(isPresented: $isMenuPresented) { statusItem in
            if !initialized {
                initialize()
                initialized = true
            }

            if let button = statusItem.button {
                let mouseHandlerView = MouseHandlerView(frame: button.frame)

                mouseHandlerView.onMouseDown = {
                    if popover.isShown {
                        popover.performClose(nil)
                    } else {
                        popover.show(relativeTo: button.bounds, of: button, preferredEdge: NSRectEdge.maxY)
                        popover.contentViewController?.view.window?.makeKey()
                    }
                }

                button.addSubview(mouseHandlerView)
            }
        }
        Settings {
            SettingView(apiKey: $apiKey)
                .onClosed {
                    scheduleUpdate()
                }
        }
    }
}
