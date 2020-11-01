//
//  LocationMessage.swift
//  Message App
//
//  Created by Nguyen Quoc Huy on 11/1/20.
//

import Foundation
import MessageKit
import CoreLocation
class LocationMessage: NSObject, LocationItem {
    var location: CLLocation
    
    var size: CGSize
    
    init(location: CLLocation) {
        self.location = location
        self.size = CGSize(width: 200, height: 200)
    }
}
