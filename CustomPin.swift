//
//  CustomPin.swift
//  AKSwiftSlideMenu
//
//  Created by Lion User on 2017-05-22.
//  Copyright © 2017 Kode. All rights reserved.
//

import MapKit

class CustomPin: NSObject, MKAnnotation {
    
    var coordinate: CLLocationCoordinate2D
    var phone: String!
    var name: String!
    var myDescription: String!
    var address: String!
    var image: UIImage!
    var id: Int = 0
    
    init(coordinate: CLLocationCoordinate2D) {
        self.coordinate = coordinate
        
    }
}
