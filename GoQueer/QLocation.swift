//
//  QLocation.swift
//  AKSwiftSlideMenu
//
//  Created by Lion User on 2017-05-27.
//  Copyright © 2017 Kode. All rights reserved.
//

import Foundation

class QLocation {
    var id:Int = 0
    var name: String?
    var description: String?
    var coordinate: String?
    var address: String?
    var type: String?
    var galleryId: Int = 0
    var userId: Int = 0
    public func getType() -> String {
        let result = coordinate?.components(separatedBy: "{type:Feature,properties:{},geometry:{")[1]
        let typeCoordinate = result?.components(separatedBy: "type:")[1]
        return (typeCoordinate?.components(separatedBy: ",")[0])!
    }
    
    public func getCoordinate() -> String {
        let result = coordinate?.components(separatedBy: "{type:Feature,properties:{},geometry:{")[1]
        let typeCoordinate = result?.components(separatedBy: "type:")[1]
        let result1 = (typeCoordinate?.components(separatedBy: ",coordinates:[")[1])!
        let result2 = result1.components(separatedBy: "]")[0]
        return result2
    }
    public func getLat() -> String {
        return getCoordinate().components(separatedBy: ",")[1]
    }
    public func getlong() -> String {
        return getCoordinate().components(separatedBy: ",")[0]
    }

}
