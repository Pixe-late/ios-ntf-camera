//
//  NetworkFactory.swift
//  Pixelate
//
//  Created by Taneja-Mac on 03/09/18.
//  Copyright © 2018 Taneja-Mac. All rights reserved.
//

import Foundation
import DataStoreKit

class NetworkFactory {
    
    class func createClient() -> NetworkInterface{
        let net = MyNetworkClient()
        return net
    }
}
