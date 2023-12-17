//
//  MyDevice.swift
//  Pixelate
//
//  Created by Taneja-Mac on 26/02/19.
//  Copyright © 2019 Taneja-Mac. All rights reserved.
//

import Foundation

class MyDevice: NSObject {
    
    static func setUserLoggedIn() {
        UserDefaults.standard.set(true, forKey: "userLoggedIn")
    }
    
    static func userLoggedIn() -> Bool {
        return UserDefaults.standard.bool(forKey: "userLoggedIn")
    }
}
