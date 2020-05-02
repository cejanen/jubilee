//
//  DataLoader.swift
//  com.commemoratemessenger
//
//  Created by Tomas Cejka on 3/30/20.
//  Copyright © 2020 CJ. All rights reserved.
//

import Foundation

final class DataLoader {
    private let testDataFileUrl = Bundle.main.url(forResource: "testShort", withExtension: "json")!
    private let fullDataFileUrl = Bundle.main.url(forResource: "testFull", withExtension: "json")!

    private var allMessages: [Message] = []

    func loadData() -> [Message] {
        do {
            let data = try Data(contentsOf: testDataFileUrl, options: .mappedIfSafe)
            let messages = try JSONDecoder().decode([Message].self, from: data)
            let sortedmessages = messages.sorted { $0.sentDate < $1.sentDate }
            self.allMessages = sortedmessages
            return sortedmessages
        }
        catch {
            // handle error
            print(error)
            return []
        }
    }

    func loadDataUntil(date: Date?) -> [Message] {
        let data = loadData()
        if let date = date {
            let lastShowedMessageIndex = data.firstIndex { $0.sentDate == date }
            if let index = lastShowedMessageIndex {
                if index < data.count - 1 {
                    return Array(data.prefix(upTo: index + 2))
                }
                return Array(data.prefix(upTo: index))
            }
        }
        return Array(data.prefix(upTo: 1))
    }

    func nextMessage(after message: Message) -> Message? {
        if let index = allMessages.firstIndex(where: { $0.messageId == message.messageId }), allMessages.count - 2 > index {
            return allMessages[index + 1]
        }

        return nil
    }
}
