import UserNotifications

enum Notification {
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
