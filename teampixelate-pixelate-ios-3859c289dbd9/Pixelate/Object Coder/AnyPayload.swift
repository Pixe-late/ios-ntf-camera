//
//  AnyPayload.swift
//  Pixelate
//
//  Created by Taneja-Mac on 03/09/18.
//  Copyright © 2018 Taneja-Mac. All rights reserved.
//

import Foundation
import DataStoreKit

class AnyPayload : ObjectCoder{
    
    var dictionary:[String:Any]
    required init(dictionary withDictionary: [String:Any]) {
        self.dictionary = withDictionary
    }
    
    public func toDictionary() -> [String:Any] {
        
        var dic = [String:Any]()
        let keys = self.dictionary.keys
        for key in keys {
            dic[key] = self.dictionary[key]
        }
        return dic
    }
    
    static func identifierKey() -> String {
        return ""
    }
}
