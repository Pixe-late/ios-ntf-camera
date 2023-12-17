//
//  PixelateData.swift
//  Pixelate
//
//  Created by Taneja-Mac on 25/03/19.
//  Copyright © 2019 Taneja-Mac. All rights reserved.
//

import Foundation
import DataStoreKit

class PixelateData: ObjectCoder {
    
    var _id: String?
    var imageNumber: String?
    var gps: String?
    var aperture: String?
    var shutterSpeed: String?
    var iso: String?
    var createdAt: String?
    var updatedAt: String?
    var mode: String?
    
    required init(dictionary withDictionary: [String : Any]) {
        self._id = withDictionary["_id"] as? String
        self.imageNumber = withDictionary["imageNumber"] as? String
        self.gps = withDictionary["gps"] as? String
        self.aperture = withDictionary["aperture"] as? String
        self.shutterSpeed = withDictionary["shutterSpeed"] as? String
        self.iso = withDictionary["iso"] as? String
        self.createdAt = withDictionary["createdAt"] as? String
        self.updatedAt = withDictionary["updatedAt"] as? String
        self.mode = withDictionary["mode"] as? String
    }
    
    static func toArray(_ arrayDic: [[String:Any]]?) -> [PixelateData] {
        let arrayItems = arrayDic ?? [[String:Any]]()
        let pixelateDataArray = arrayItems.map { (item:[String : Any]) -> PixelateData in
            return PixelateData(dictionary: item)
        }
        return pixelateDataArray
    }
    
    func toDictionary() -> [String : Any] {
        var dic: [String:Any] = [String:Any]()
        self._id != nil ? dic["_id"] = self._id! : ()
        self.imageNumber != nil ? dic["imageNumber"] = self.imageNumber! : ()
        self.gps != nil ? dic["gps"] = self.gps! : ()
        self.aperture != nil ? dic["aperture"] = self.aperture! : ()
        self.shutterSpeed != nil ? dic["shutterSpeed"] = self.shutterSpeed! : ()
        self.iso != nil ? dic["iso"] = self.iso! : ()
        self.createdAt != nil ? dic["createdAt"] = self.createdAt! : ()
        self.updatedAt != nil ? dic["updatedAt"] = self.updatedAt! : ()
        self.mode != nil ? dic["mode"] = self.mode! : ()
        return dic
    }
    
    static func identifierKey() -> String {
        return "_id"
    }
}
