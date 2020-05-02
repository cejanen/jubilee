//
//  Color+CustomColors.swift
//  com.commemoratemessenger
//
//  Created by Tomas Cejka on 4/14/20.
//  Copyright © 2020 CJ. All rights reserved.
//

import UIKit

extension UIColor {
    static var incomingGray: UIColor {
        if #available(iOS 13, *) {
            return UIColor.systemGray5
        } else {
            return UIColor(red: 230/255, green: 230/255, blue: 235/255, alpha: 1.0)
        }
    }

    static var incomingGrayDarker: UIColor {
        if #available(iOS 13, *) {
            return UIColor.systemGray2
        } else {
            return UIColor(red: 215/255, green: 215/255, blue: 220/255, alpha: 1.0)
        }
    }

    static var outgoingGreen: UIColor {
        if #available(iOS 13, *) {
            return UIColor.systemBlue
        } else {
            return .blue
        }
    }

    static var outgoingGreenLighter: UIColor {
        if #available(iOS 13, *) {
            return UIColor.systemTeal
        } else {
            return .cyan
        }
    }
}
