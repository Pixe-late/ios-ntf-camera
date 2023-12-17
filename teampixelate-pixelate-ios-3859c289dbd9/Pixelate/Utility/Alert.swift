//
//  Alert.swift
//  Pixelate
//
//  Created by Taneja-Mac on 18/10/18.
//  Copyright © 2018 Taneja-Mac. All rights reserved.
//

import Foundation
import UIKit

class Alert {
    static let shared: Alert = Alert()
    
    func show(_ on: UIViewController, withTitle: String, alert: String) {
        let alertVC = UIAlertController(title: withTitle, message: alert, preferredStyle: .alert)
        alertVC.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        on.present(alertVC, animated: true) {
        }
    }
    
    func show(_ on: UIViewController, alert: String) {
        self.show(on, withTitle: "Pixelate", alert: alert)
    }
}
