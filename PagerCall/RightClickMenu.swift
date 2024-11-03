import SwiftUI

struct RightClickMenu: View {
    @AppStorage("subdomain") private var subdomain = ""
    @AppStorage("userID") private var userID = ""

    var body: some View {
        Button("My Incidents") {
            Task {
                let url = URL(string: "https://\(subdomain).pagerduty.com/incidents?assignedToUser=\(userID)")!
                NSWorkspace.shared.open(url)
            }
        }
        Button("My On-Call Shifts") {
            Task {
                let url = URL(string: "https://\(subdomain).pagerduty.com/my-on-call/week")!
                NSWorkspace.shared.open(url)
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
