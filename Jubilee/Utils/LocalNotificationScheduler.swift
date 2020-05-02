//
//  LocalNotificationScheduler.swift
//  Jubilee
//
//  Created by Tomas Cejka on 4/14/20.
//  Copyright © 2020 CJ. All rights reserved.
//

import UIKit
import UserNotifications

final class LocalNotificationScheduler {
    private lazy var notificationCenter = UNUserNotificationCenter.current()
    private let notificationRequestIdentifier = "cz.ceja.jubilee.notification"
    private lazy var userDefaultsManager = UserDefaultsManager()

    func scheduleNextMessage(message: Message) {
        checkNotificationsSettings { [weak self] allowed in
            guard let self = self else {
                return
            }
            if allowed {
                let lastDate = self.userDefaultsManager.lastNotificationDate()
                let currentDate = Date()

                if let lastDateValue = lastDate, currentDate.timeIntervalSince1970 - lastDateValue.timeIntervalSince1970 < 3600 {
                    return
                }

                let notification = self.createNotification(message: message)
                self.scheduleNotification(notification: notification, date: message.sentDate)
            }
        }
    }

    func cancelAllScheduledRequests() {
        notificationCenter.removePendingNotificationRequests(withIdentifiers: [notificationRequestIdentifier])
        notificationCenter.removeDeliveredNotifications(withIdentifiers: [notificationRequestIdentifier])
    }

    func scheduleNotification(notification: UNMutableNotificationContent, date: Date) {
        let calendar = Calendar.current
        var dateComponents = calendar.dateComponents([.day, .month, .hour, .minute], from: date)
        dateComponents.year = 2020
        dateComponents.hour! -= 1
     
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
        let request = UNNotificationRequest(identifier: notificationRequestIdentifier, content: notification, trigger: trigger)
        notificationCenter.add(request, withCompletionHandler: { error in
            print("Notification error \(error)")
        })
    }

    func createNotification(message: Message) -> UNMutableNotificationContent {
        let content = UNMutableNotificationContent()

        content.title = "Máte novou zprávu"
        content.userInfo = [:]
        content.body = message.text
        content.sound = UNNotificationSound.default
        content.badge = 1

        return content
    }

    func checkNotificationsSettings(completion: @escaping (Bool) -> Void) {
        notificationCenter.getNotificationSettings { settings in
            completion(settings.authorizationStatus == .authorized)
        }
    }
}
