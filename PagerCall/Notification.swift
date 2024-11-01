import SwiftUI
import UserNotifications

enum Notification {
    static func initialize() {
        let userNotificationCenter = UNUserNotificationCenter.current()

        userNotificationCenter.requestAuthorization(options: [.alert, .sound]) { authorized, _ in
            guard authorized else {
                Logger.shared.warning("user notificationCentern not authorized")
                return
            }
        }
    }

    static func notify(id: String, title: String? = nil, body: String? = nil, url: String? = nil) async {
        let userNotificationCenter = UNUserNotificationCenter.current()

        let content = UNMutableNotificationContent()

        if let title {
            content.title = title
        }

        if let body {
            content.body = body
        }

        if let url {
            content.userInfo = ["url": url]
        }

        content.sound = UNNotificationSound.default
        let req = UNNotificationRequest(identifier: "\(Bundle.main.bundleIdentifier!).\(id)", content: content, trigger: nil)
        try? await userNotificationCenter.add(req)
    }
}

class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationDidFinishLaunching(_: Foundation.Notification) {
        UNUserNotificationCenter.current().delegate = self
    }
}

extension AppDelegate: UNUserNotificationCenterDelegate {
    func userNotificationCenter(_: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        let userInfo = response.notification.request.content.userInfo

        guard let url = userInfo["url"] as? String else {
            fatalError("failed to cast userInfo['url'] to String")
        }

        NSWorkspace.shared.open(URL(string: url)!)
        completionHandler()
    }
}
