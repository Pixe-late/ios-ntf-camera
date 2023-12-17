//
//  Formatter+Extension.swift
//  Pixelate
//
//  Created by Taneja-Mac on 10/09/18.
//  Copyright © 2018 Taneja-Mac. All rights reserved.
//

import Foundation

extension Formatter {
    static let iso8601: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return formatter
    }()
}
