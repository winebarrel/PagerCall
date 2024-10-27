import SwiftUI

struct RightClickMenu: View {
    private let api = PagerDutyAPI()

    var body: some View {
        Button("My Incidents") {
            Task {
                do {
                    let url = try await api.getIncidentsURL()
                    NSWorkspace.shared.open(url)
                } catch {
                    Logger.shared.error("failed to open 'My Incidents': \(error)")
                }
            }
        }
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
