//
//  MapAnnotation.swift
//  Message App
//
//  Created by Nguyen Quoc Huy on 11/1/20.
//

import Foundation

import MapKit

class MapAnnotation: NSObject, MKAnnotation {
    let title: String?
    let coordinate: CLLocationCoordinate2D
    init(title: String?, coordinate: CLLocationCoordinate2D) {
        self.title = title
        self.coordinate = coordinate
    }
}
