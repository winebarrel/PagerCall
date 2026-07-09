import SwiftUI

struct RightClickMenuView: View {
    @AppStorage("subdomain") private var subdomain = ""
    @AppStorage("userID") private var userID = ""
    @AppStorage("region") private var region = Region.us

    var body: some View {
        Button("My Incidents") {
            Task {
                let base = region.webBaseURL(subdomain: subdomain)
                let url = base.appending(path: "incidents")
                    .appending(queryItems: [URLQueryItem(name: "assignedToUser", value: userID)])
                NSWorkspace.shared.open(url)
            }
        }
        Button("My On-Call Shifts") {
            Task {
                let base = region.webBaseURL(subdomain: subdomain)
                let url = base.appending(path: "my-on-call/week")
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
