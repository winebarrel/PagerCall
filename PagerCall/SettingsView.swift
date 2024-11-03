import ServiceManagement
import SwiftUI

struct SettingView: View {
    @State var apiKey: String = Vault.apiKey
    @AppStorage("subdomain") private var subdomain = ""
    @AppStorage("userID") private var userID = ""
    @AppStorage("interval") private var interval = Constants.defaultInterval
    @State private var launchAtLogin: Bool = SMAppService.mainApp.status == .enabled

    var body: some View {
        Form {
            SecureField(text: $apiKey) {
                Link("API Key", destination: URL(string: "https://support.pagerduty.com/main/docs/api-access-keys")!)
            }.onChange(of: apiKey) {
                Vault.apiKey = apiKey
            }
            TextField("Subdomain", text: $subdomain)
            TextField("User ID", text: $userID)
            TextField("Interval (sec)", value: $interval, format: .number.grouping(.never))
                .onChange(of: interval) {
                    if interval < 1 {
                        interval = 1
                    } else if interval > 3600 {
                        interval = 3600
                    }
                }
            Toggle("Launch at login", isOn: $launchAtLogin)
                .onChange(of: launchAtLogin) {
                    do {
                        if launchAtLogin {
                            try SMAppService.mainApp.register()
                        } else {
                            try SMAppService.mainApp.unregister()
                        }
                    } catch {
                        Logger.shared.error("failed to update 'Launch at login': \(error)")
                    }
                }
            Link(destination: URL(string: "https://github.com/winebarrel/PagerCall")!) {
                // swiftlint:disable force_cast
                let appVer = Bundle.main.infoDictionary!["CFBundleShortVersionString"] as! String
                let buildVer = Bundle.main.infoDictionary!["CFBundleVersion"] as! String
                // swiftlint:enable force_cast
                Text("Ver. \(appVer).\(buildVer)")
            }
            .frame(maxWidth: .infinity, alignment: .trailing)
        }
        .padding(20)
        .frame(width: 400)
    }

    func onClosed(_ action: @escaping () -> Void) -> some View {
        onReceive(NotificationCenter.default.publisher(for: NSWindow.willCloseNotification)) { notification in
            if let window = notification.object as? NSWindow, window.title == "PagerCall Settings" {
                action()
            }
        }
    }
}

#Preview {
    SettingView()
}
