import SwiftUI

@main
struct PagerCallApp: App {
    @State private var apiKey = Vault.apiKey

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
