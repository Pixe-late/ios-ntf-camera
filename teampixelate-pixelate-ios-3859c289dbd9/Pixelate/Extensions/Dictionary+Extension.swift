//
//  Dictionary+Extension.swift
//  Pixelate
//
//  Created by Taneja-Mac on 03/09/18.
//  Copyright © 2018 Taneja-Mac. All rights reserved.
//

import Foundation

extension Dictionary {
    
    func stringFromHttpParameters() -> String {
        let parameterArray = self.map { (key, value) -> String in
            let nonNilValue:String = value is NSNumber ? "\(value as? NSNumber ?? 0)" : (value as? String ?? "")
            let percentEscapedKey = (key as? String ?? "").addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed) ?? "nokey"
            let percentEscapedValue = nonNilValue.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed) ?? "novalue"
            return "\(percentEscapedKey)=\(percentEscapedValue)"
        }
        
        return parameterArray.joined(separator: "&")
    }
}
