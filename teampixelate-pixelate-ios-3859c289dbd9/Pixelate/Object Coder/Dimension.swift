//
//  Dimension.swift
//  Pixelate
//
//  Created by Taneja-Mac on 31/08/18.
//  Copyright © 2018 Taneja-Mac. All rights reserved.
//

import Foundation
import DataStoreKit

class Dimension: ObjectCoder {
    var width: String?
    var height: String?
    
    required init(dictionary withDictionary: [String : Any]) {
        self.width = withDictionary["width"] as? String
        self.height = withDictionary["height"] as? String
    }
    
    func toDictionary() -> [String : Any] {
        var dic: [String:Any] = [String:Any]()
        self.width != nil ? dic["width"] = self.width! : ()
        self.height != nil ? dic["height"] = self.height! : ()
        return dic
    }
    
    static func identifierKey() -> String {
        return ""
    }
}
