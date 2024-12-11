import UserNotifications

enum Notification {
    static func initialize() {
        let userNotificationCenter = UNUserNotificationCenter.current()

        userNotificationCenter.requestAuthorization(options: [.alert, .sound]) { authorized, _ in
            guard authorized else {
                Logger.shared.warning("user notification not authorized")
                return
            }
        }
    }

    static func notify(id: String, title: String, body: String, url: String) async {
        let userNotificationCenter = UNUserNotificationCenter.current()

        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.userInfo = ["url": url]
        content.sound = UNNotificationSound.default

        let req = UNNotificationRequest(identifier: "\(Bundle.main.bundleIdentifier!).\(id)", content: content, trigger: nil)
        try? await userNotificationCenter.add(req)
    }
}
