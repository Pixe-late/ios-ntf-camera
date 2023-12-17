//
//  ModelFactory.swift
//  Pixelate
//
//  Created by Taneja-Mac on 03/09/18.
//  Copyright © 2018 Taneja-Mac. All rights reserved.
//

import Foundation
import DataStoreKit

class ModelFactory {
    
    class func imageConfiguration() -> Restify<AnyPayload> {
        let path = Constants.URL.BASE + Constants.URL.CREATE_CONTRACT
        let client = NetworkFactory.createClient()
        return Restify<AnyPayload>(path: path, networkClient: client)
    }
    
    class func login(username:String,password:String) -> Restify<AnyPayload> {
        let cridentialString: String = "\(username):\(password)"
        let cridentialData: Data = cridentialString.data(using: String.Encoding.utf8)!
        let base64LoginString = cridentialData.base64EncodedString()
        let client = NetworkFactory.createClient()
        client.setHTTPHeaders(["Authorization":"Basic \(base64LoginString)"])
        let path = Constants.URL.BASE + Constants.URL.AUTH
        return Restify<AnyPayload>(path: path, networkClient: client)
    }
    
    class func pixelateData() -> Restify<PixelateData> {
        let cridentialString: String = "Pixelate-:Password-"
        let cridentialData: Data = cridentialString.data(using: String.Encoding.utf8)!
        let base64LoginString = cridentialData.base64EncodedString()
        let client = NetworkFactory.createClient()
        client.setHTTPHeaders(["Authorization":"Basic \(base64LoginString)"])
        let path = Constants.URL.BASE + Constants.URL.GET_DB_DATA
        return Restify<PixelateData>(path: path, networkClient: client)
    }
    
    class func networkPixelateData() -> Restify<PixelateData> {
        let cridentialString: String = "Pixelate-:Password-"
        let cridentialData: Data = cridentialString.data(using: String.Encoding.utf8)!
        let base64LoginString = cridentialData.base64EncodedString()
        let client = NetworkFactory.createClient()
        client.setHTTPHeaders(["Authorization":"Basic \(base64LoginString)"])
        let path = Constants.URL.BASE + Constants.URL.SET_DB_DATA
        return Restify<PixelateData>(path: path, networkClient: client)
    }
}
