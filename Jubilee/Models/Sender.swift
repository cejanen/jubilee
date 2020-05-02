//
//  Sender.swift
//  com.commemoratemessenger
//
//  Created by Tomas Cejka on 3/30/20.
//  Copyright © 2020 CJ. All rights reserved.
//

import Foundation
import MessageKit

struct Sender: SenderType, Decodable {
    let senderId: String
    let displayName: String

    init(displayName: String) {
        senderId = displayName
        self.displayName = displayName
    }
}
