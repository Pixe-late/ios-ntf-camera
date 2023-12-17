//
//  Location.swift
//  Pixelate
//
//  Created by Taneja-Mac on 31/08/18.
//  Copyright © 2018 Taneja-Mac. All rights reserved.
//

import Foundation
import DataStoreKit

class Location: ObjectCoder {
    var type: String?
    var coordinates: [String]?
    
    required init(dictionary withDictionary: [String : Any]) {
        self.type = withDictionary["type"] as? String
        self.coordinates = withDictionary["coordinates"] as? [String]
    }
    
    func toDictionary() -> [String : Any] {
        var dic: [String:Any] = [String:Any]()
        self.type != nil ? dic["type"] = self.type! : ()
        self.coordinates?.count == 2 ? dic["coordinates"] = self.coordinates! : ()
        return dic
    }
    
    static func identifierKey() -> String {
        return ""
    }
}
