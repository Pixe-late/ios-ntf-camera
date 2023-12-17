//
//  UIView+Extension.swift
//  Pixelate
//
//  Created by Taneja-Mac on 18/10/18.
//  Copyright © 2018 Taneja-Mac. All rights reserved.
//

import Foundation
import UIKit

extension UIView {
    func borderMe() {
        self.borderMe(thickness: 1.0)
    }
    
    func borderMe(thickness: CGFloat) {
        self.layer.borderWidth = thickness
    }
    
    func borderColor(color: UIColor) {
        self.layer.borderColor = color.cgColor
    }
}
