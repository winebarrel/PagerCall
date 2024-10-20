import ServiceManagement
import SwiftUI

struct SettingView: View {
    @Binding var apiKey: String
    @AppStorage("interval") private var interval: TimeInterval = Constants.defaultInterval
    @AppStorage("userID") private var userID = ""
    @State private var launchAtLogin: Bool = SMAppService.mainApp.status == .enabled

    var body: some View {
        Form {
            SecureField(text: $apiKey) {
                Link("API Key", destination: URL(string: "https://support.pagerduty.com/main/docs/api-access-keys")!)
            }
            // TODO:
            TextField("Interval (sec)", value: $interval, format: .number.grouping(.never))
                .onChange(of: interval) {
                    if interval < 1 {
                        interval = 1
                    } else if interval > 3600 {
                        interval = 3600
                    }
                }
            TextField("User ID (optional)", text: $userID)
            Toggle("Launch at login", isOn: $launchAtLogin)
                .onChange(of: launchAtLogin) {
                    do {
                        if launchAtLogin {
                            try SMAppService.mainApp.register()
                        } else {
                            try SMAppService.mainApp.unregister()
                        }
                    } catch {
                        // TODO: logging
                    }
                }
        }
        .padding(20)
        .frame(width: 400)
    }
}
