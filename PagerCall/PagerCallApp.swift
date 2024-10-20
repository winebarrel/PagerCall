import SwiftUI

@main
struct PagerCallApp: App {
    @State private var apiKey = "" // TODO:

    var body: some Scene {
        MenuBarExtra {
            RightClickMenu()
        } label: {
            Image(systemName: "leaf")
        }
        Settings {
            SettingView(apiKey: $apiKey)
        }
    }
}
