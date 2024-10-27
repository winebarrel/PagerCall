import MenuBarExtraAccess
import SwiftUI
import UserNotifications

@main
struct PagerCallApp: App {
    @State private var initialized = false
    @State private var isMenuPresented = false
    @State private var timer: Timer?
    @AppStorage("interval") private var interval = Constants.defaultInterval
    @StateObject private var pagerDuty = PagerDuty()

    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    private var popover: NSPopover = {
        let pop = NSPopover()
        pop.behavior = .transient
        pop.animates = false
        pop.contentSize = NSSize(width: 500, height: 400)
        return pop
    }()

    private func initialize() {
        Notification.initialize()

        let contentView = ContentView(pagerDuty: pagerDuty)
        popover.contentViewController = NSHostingController(rootView: contentView)

        scheduleUpdate()
    }

    private func scheduleUpdate() {
        // TODO: Use async scheduler
        // cf. https://zenn.dev/treastrain/articles/a78b5f892f4654
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { _ in
            Task {
                await pagerDuty.update()
            }
        }
        timer?.fire()
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
            SettingView()
                .onClosed {
                    scheduleUpdate()
                }
        }
    }
}
