//
//  UserDefaultsManager.swift
//  com.commemoratemessenger
//
//  Created by Tomas Cejka on 4/14/20.
//  Copyright © 2020 CJ. All rights reserved.
//

import Foundation

final class UserDefaultsManager {
    private let lastOpenedMessageDateKey = "cz.ceja.jubilee.lastOpenedMessageDate"
    private let lastNotificationDateKey = "cz.ceja.jubilee.lastNotificationDate"
    private lazy var userDefaults = UserDefaults()

    func storeLastOpenMessageDate(date: Date?) {
        userDefaults.set(date, forKey: lastOpenedMessageDateKey)
        userDefaults.synchronize()
    }

    func lastOpenMessageDate() -> Date? {
        return userDefaults.object(forKey: lastOpenedMessageDateKey) as? Date
    }

    func storeLastNotificationDate(date: Date?) {
        userDefaults.set(date, forKey: lastNotificationDateKey)
        userDefaults.synchronize()
    }

    func lastNotificationDate() -> Date? {
        return userDefaults.object(forKey: lastNotificationDateKey) as? Date
    }
}
