import Foundation
import UIKit
import UserNotifications

class NotificationService: NSObject {
    static let shared = NotificationService()
    
    private let notificationCenter = UNUserNotificationCenter.current()
    private var deviceToken: String?
    
    private override init() {
        super.init()
        notificationCenter.delegate = self
    }
    
    // MARK: - Authorization
    
    func requestAuthorization() {
        notificationCenter.requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            if let error = error {
                Logger.error("Notification authorization error: \(error)")
                return
            }
            
            if granted {
                Logger.debug("Notification authorization granted")
                DispatchQueue.main.async {
                    UIApplication.shared.registerForRemoteNotifications()
                }
            } else {
                Logger.debug("Notification authorization denied")
            }
        }
    }
    
    // MARK: - Device Token
    
    func registerDeviceToken(_ token: Data) {
        let tokenString = token.map { String(format: "%02.2hhx", $0) }.joined()
        self.deviceToken = tokenString
        Logger.debug("Device token: \(tokenString)")
        
        // TODO: Send token to backend
        // Task {
        //     try? await APIService.shared.registerDeviceToken(tokenString)
        // }
    }
    
    func handleRegistrationError(_ error: Error) {
        Logger.error("Failed to register for remote notifications: \(error)")
    }
    
    // MARK: - Local Notifications
    
    func showLocalNotification(title: String, body: String, identifier: String = UUID().uuidString) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default
        content.badge = 1
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        
        notificationCenter.add(request) { error in
            if let error = error {
                Logger.error("Failed to schedule local notification: \(error)")
            } else {
                Logger.debug("Local notification scheduled: \(title)")
            }
        }
    }
    
    // MARK: - Badge Management
    
    func clearBadge() {
        DispatchQueue.main.async {
            UIApplication.shared.applicationIconBadgeNumber = 0
        }
    }
    
    func setBadge(_ count: Int) {
        DispatchQueue.main.async {
            UIApplication.shared.applicationIconBadgeNumber = count
        }
    }
}

// MARK: - UNUserNotificationCenterDelegate

extension NotificationService: UNUserNotificationCenterDelegate {
    // Handle notifications when app is in foreground
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        Logger.debug("Notification received in foreground: \(notification.request.content.title)")
        
        // Show notification even when app is in foreground
        completionHandler([.banner, .sound, .badge])
    }
    
    // Handle notification tap
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        let userInfo = response.notification.request.content.userInfo
        Logger.debug("Notification tapped: \(userInfo)")
        
        // Handle notification action
        if let flagId = userInfo["flagId"] as? String {
            // TODO: Navigate to flag detail
            NotificationCenter.default.post(
                name: NSNotification.Name("NavigateToFlag"),
                object: nil,
                userInfo: ["flagId": flagId]
            )
        }
        
        completionHandler()
    }
}
