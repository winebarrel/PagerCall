import SwiftUI

struct RightClickMenu: View {
    @AppStorage("subdomain") private var subdomain = ""

    var body: some View {
        Button("My Incidents") {
            Task {
                NSWorkspace.shared.open(URL(string: "https://\(subdomain).pagerduty.com/incidents")!)
            }
        }
        Button("My On-Call Shifts") {
            Task {
                NSWorkspace.shared.open(URL(string: "https://\(subdomain).pagerduty.com/my-on-call/week")!)
            }
        }
        Divider()
        SettingsLink {
            Text("Settings")
        }.preActionButtonStyle {
            NSApp.activate(ignoringOtherApps: true)
        }
        Divider()
        Button("Quit") {
            NSApplication.shared.terminate(self)
        }
    }
}
