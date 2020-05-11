//
//  Message.swift
//  com.commemoratemessenger
//
//  Created by Tomas Cejka on 3/30/20.
//  Copyright © 2020 CJ. All rights reserved.
//

import Foundation
import MessageKit

struct Message: Decodable {
    enum MessageSource: Int, Decodable {
        case messenger
        case sms

        var text: String {
            switch self {
            case .sms:
                return "SMS"
            case .messenger:
                return "FB"
            }
        }
    }

    let messageId: String = UUID().uuidString
    let date: String
    let text: String
    let isMyMessage: Bool
    let type: MessageSource

    private enum CodingKeys: String, CodingKey {
        case date = "Date"
        case text = "Text"
        case isMyMessage = "IsMyMessage"
        case type = "Type"
    }
}

// MARK: - MessageType
extension Message: MessageType {
    var sender: SenderType {
        isMyMessage ? Sender(displayName: "Radek") : Sender(displayName: "Misa")
    }

    var kind: MessageKind {
        .text(text)
    }

    var sentDate: Date {
        let dateFormatter = DateFormatter()
        // 2014-03-22T13:58:04.5574257+01:00
        print("date original: \(date)")
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        print("date formatted: \(dateFormatter.date(from: date))")
        return dateFormatter.date(from: date) ?? Date()
    }
}

