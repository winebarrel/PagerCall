import MenuBarExtraAccess
import SwiftUI

@main
struct PagerCallApp: App {
    @State private var initialized = false
    @State private var isMenuPresented = false
    @StateObject private var pagerDuty = PagerDuty()

    private var popover: NSPopover = {
        let pop = NSPopover()
        pop.behavior = .transient
        pop.animates = false
        pop.contentSize = NSSize(width: 500, height: 400)
        return pop
    }()

    private func initialize() {
        // TODO: notification

        popover.contentViewController = NSHostingController(rootView: ContentView())
    }

    var body: some Scene {
        MenuBarExtra {
            RightClickMenu()
        } label: {
            // TODO:
            Image(systemName: "leaf")
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
        }
    }
}
