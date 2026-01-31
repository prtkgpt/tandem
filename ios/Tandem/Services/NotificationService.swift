import Foundation
import UserNotifications

class NotificationService {
    static let shared = NotificationService()

    private init() {}

    func requestPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            if granted {
                print("Notification permission granted")
            }
        }
    }

    func scheduleDailyTopicReminder(hour: Int, minute: Int) {
        let center = UNUserNotificationCenter.current()
        center.removePendingNotificationRequests(withIdentifiers: ["dailyTopic"])

        let content = UNMutableNotificationContent()
        content.title = "Table Topics Time! \u{1F4AC}"
        content.body = "Tonight's conversation starter is ready. Tap to see today's question."
        content.sound = .default

        var dateComponents = DateComponents()
        dateComponents.hour = hour
        dateComponents.minute = minute

        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        let request = UNNotificationRequest(identifier: "dailyTopic", content: content, trigger: trigger)

        center.add(request)
    }

    func scheduleWeeklySummaryReminder() {
        let center = UNUserNotificationCenter.current()
        center.removePendingNotificationRequests(withIdentifiers: ["weeklySummary"])

        let content = UNMutableNotificationContent()
        content.title = "Your State of Us is ready! \u{1F495}"
        content.body = "See how your week together went."
        content.sound = .default

        var dateComponents = DateComponents()
        dateComponents.weekday = 1 // Sunday
        dateComponents.hour = 20
        dateComponents.minute = 0

        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        let request = UNNotificationRequest(identifier: "weeklySummary", content: content, trigger: trigger)

        center.add(request)
    }
}
