import ServiceManagement
import SwiftUI
import VersionCompare

struct SettingView: View {
    @Binding var apiKey: String
    @AppStorage("subdomain") private var subdomain = ""
    @AppStorage("userID") private var userID = ""
    @AppStorage("interval") private var interval = Constants.defaultInterval
    @AppStorage("sortBy") private var sortBy = ItemOrder.incidentMumberAsc
    @State private var launchAtLogin: Bool = SMAppService.mainApp.status == .enabled
    @State private var showNewVersion = true

    var body: some View {
        Form {
            SecureField(text: $apiKey) {
                Link("API Key", destination: URL(string: "https://support.pagerduty.com/main/docs/api-access-keys")!)
                    .effectHoverCursor()
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
            Picker("Sort By", selection: $sortBy) {
                ForEach(ItemOrder.allCases, id: \.self) { order in
                    Text(order.rawValue).tag(order)
                }
            }.pickerStyle(.menu)
            HStack {
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
                if showNewVersion {
                    Link(destination: URL(string: "https://apps.apple.com/app/pagercall/id6740581987")!) {
                        Text("New version available")
                            .font(.footnote)
                            .padding(.horizontal, 3)
                            .foregroundColor(.white)
                            .background(.blue, in: RoundedRectangle(cornerRadius: 5))
                    }
                    .effectHoverCursor()
                    .frame(maxWidth: .infinity, alignment: .trailing)
                }
            }
            HStack {
                // swiftlint:disable force_cast
                let appVer = Bundle.main.infoDictionary!["CFBundleShortVersionString"] as! String
                // swiftlint:enable force_cast
                Text("Version. \(appVer)")
                    .frame(maxWidth: .infinity, alignment: .trailing)
                Link(destination: URL(string: "https://github.com/winebarrel/PagerCall")!) {
                    Image("github-mark")
                        .resizable()
                        .frame(width: 16, height: 16)
                }
                .effectHoverCursor()
            }
            .frame(maxWidth: .infinity, alignment: .trailing)
        }
        .padding(20)
        .frame(width: 400)
        .onAppear {
            Task {
                // swiftlint:disable force_cast
                let bundleId = Bundle.main.infoDictionary!["CFBundleIdentifier"] as! String
                let appVer = Bundle.main.infoDictionary!["CFBundleShortVersionString"] as! String
                // swiftlint:enable force_cast

                guard let info = await AppStoreAPI.getInfo(bundleId) else {
                    return
                }

                let appStoreVersion = Version(info.version)!
                let selfAppVersion = Version(appVer)!

                showNewVersion = appStoreVersion > selfAppVersion
            }
        }
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
    SettingView(apiKey: .constant(""))
}
