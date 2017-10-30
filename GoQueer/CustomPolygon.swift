//
//  CustomPolygon.swift
//  GoQueer
//
//  Created by Circa Lab on 2017-10-29.
//  Copyright © 2017 Kode. All rights reserved.
//

import MapKit

@objc class CustomPolygon: NSObject {
    var title: String?
    var subtitle: String?
    var coordinate: CLLocationCoordinate2D
    
    
    init(title: String?, subtitle: String?, coordinate: CLLocationCoordinate2D) {
        self.title = title
        self.subtitle = subtitle
        
        self.coordinate = coordinate
    }
    
 
    
    
}




extension CustomPolygon: MKAnnotation { }

