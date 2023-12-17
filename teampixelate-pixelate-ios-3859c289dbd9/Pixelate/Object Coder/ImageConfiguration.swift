//
//  ImageConfiguration.swift
//  Pixelate
//
//  Created by Taneja-Mac on 31/08/18.
//  Copyright © 2018 Taneja-Mac. All rights reserved.
//

import Foundation
import DataStoreKit

class ImageConfiguration: ObjectCoder {
    var filter: String?
    var filetype: String?
    var created_at: String?
    var color_mode: String?
    var depth: String?
    var orientation: String?
    var camera: String?
    var device: String?
    var file_size: String?
    var ev: String?
    var iso_speed: String?
    var exposure_duration: String?
    var aperture: String?
    var zoom: String?
    var pixel: Pixel?
    var dimension: Dimension?
    var location: Location?
    
    required init(dictionary withDictionary: [String : Any]) {
        self.filter = withDictionary["filter"] as? String
        self.filetype = withDictionary["filetype"] as? String
        self.created_at = withDictionary["created_at"] as? String
        self.color_mode = withDictionary["color_mode"] as? String
        self.depth = withDictionary["depth"] as? String
        self.orientation = withDictionary["orientation"] as? String
        self.camera = withDictionary["camera"] as? String
        self.device = withDictionary["device"] as? String
        self.file_size = withDictionary["file_size"] as? String
        self.ev = withDictionary["ev"] as? String
        self.iso_speed = withDictionary["iso_speed"] as? String
        self.aperture = withDictionary["aperture"] as? String
        self.zoom = withDictionary["zoom"] as? String
        self.exposure_duration = withDictionary["exposure_duration"] as? String
        self.pixel = Pixel(dictionary: withDictionary["pixel"] as? [String:Any] ?? [:])
        self.dimension = Dimension(dictionary: withDictionary["dimension"] as? [String:Any] ?? [:])
        self.location = Location(dictionary: withDictionary["location"] as? [String:Any] ?? [:])
    }
    
    func toDictionary() -> [String : Any] {
        var dic: [String:Any] = [String:Any]()
        self.filter != nil ? dic["filter"] = self.filter : ()
        self.filetype != nil ? dic["filetype"] = self.filetype : ()
        self.created_at != nil ? dic["created_at"] = self.created_at : ()
        self.color_mode != nil ? dic["color_mode"] = self.color_mode : ()
        self.depth != nil ? dic["depth"] = self.depth : ()
        self.orientation != nil ? dic["orientation"] = self.orientation : ()
        self.camera != nil ? dic["camera"] = self.camera : ()
        self.device != nil ? dic["device"] = self.device : ()
        self.file_size != nil ? dic["file_size"] = self.file_size : ()
        self.ev != nil ? dic["ev"] = self.ev : ()
        self.iso_speed != nil ? dic["iso_speed"] = self.iso_speed : ()
        self.exposure_duration != nil ? dic["exposure_duration"] = self.exposure_duration : ()
        self.aperture != nil ? dic["aperture"] = self.aperture : ()
        self.zoom != nil ? dic["zoom"] = self.zoom : ()
        ((self.pixel?.toDictionary()) != nil) ? dic["pixel"] = self.pixel!.toDictionary() : ()
        ((self.dimension?.toDictionary()) != nil) ? dic["dimension"] = self.dimension!.toDictionary() : ()
        ((self.location?.toDictionary()) != nil) ? dic["location"] = self.location!.toDictionary() : ()
        return dic
    }
    
    static func identifierKey() -> String {
        return ""
    }
}
