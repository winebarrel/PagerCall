import SwiftUI

struct RightClickMenu: View {
    var body: some View {
        Button("My Incidents") {
            Task {
                // TODO:
                let url = URL(string: "https://example.com/")!
                NSWorkspace.shared.open(url)
            }
        }
        Divider()
        Button("Quit") {
            NSApplication.shared.terminate(self)
        }
    }
}