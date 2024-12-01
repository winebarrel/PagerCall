import AppKit
import UserNotifications

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
