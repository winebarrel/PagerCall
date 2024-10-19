import SwiftUI

@main
struct PagerCallApp: App {
    var body: some Scene {
        MenuBarExtra {
            RightClickMenu()
        } label: {
            Image(systemName: "leaf")
        }
    }
}
