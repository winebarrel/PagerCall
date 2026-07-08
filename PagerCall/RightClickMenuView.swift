import SwiftUI

struct RightClickMenuView: View {
    @AppStorage("subdomain") private var subdomain = ""
    @AppStorage("userID") private var userID = ""
    @AppStorage("region") private var region = Region.us

    var body: some View {
        Button("My Incidents") {
            Task {
                let base = region.webBaseURL(subdomain: subdomain)
                let url = URL(string: "\(base.absoluteString)/incidents?assignedToUser=\(userID)")!
                NSWorkspace.shared.open(url)
            }
        }
        Button("My On-Call Shifts") {
            Task {
                let base = region.webBaseURL(subdomain: subdomain)
                let url = URL(string: "\(base.absoluteString)/my-on-call/week")!
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
