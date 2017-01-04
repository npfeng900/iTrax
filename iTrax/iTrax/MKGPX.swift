//
//  MKGPX.swift
//  iTrax
//
//  Created by Niu Panfeng on 01/01/2017.
//  Copyright © 2017 NaPaFeng. All rights reserved.
//

import MapKit

// MKAnnotation是一个协议
// 使GPX.Waypoint遵守MKAnnotation协议，即实现coordinate、title和subtitle的属性内容

extension GPX.Waypoint: MKAnnotation {
    
    /** MKAnnotation默认的3个属性，默认为大头针视图，title和subtitle等 */
    // coordinate是MKAnnotation的协议内容
    var coordinate: CLLocationCoordinate2D { return CLLocationCoordinate2D(latitude: latitude, longitude: longitude) }
    // title是MKAnnotation的协议内容，name是GPX.Entry(GPX.Waypoint的父类)的属性
    var title: String? { return name }
    // subtitle是MKAnnotation的协议内容，info是GPX.Waypoint的属性
    var subtitle: String? { return info }
    
    // get指定类型的图片URL，links是GPX.Entry(GPX.Waypoint的父类)的属性
    func getImageURLofType(type: String) -> NSURL? {
        for link in links {
            if link.type! == type {
                return link.url
            }
        }
        return nil
    }
    // thumbnailURL和imageURL的计算属性
    var thumbnailURL: NSURL? { return getImageURLofType("thumbnail") }
    var imageURL: NSURL?  { return getImageURLofType("large") }
}


// GPX.Waypoint的子类，coordinate可编辑
class EditableWaypoint: GPX.Waypoint {
    override var coordinate: CLLocationCoordinate2D {
        get {
            return super.coordinate
        }
        set {
            latitude = newValue.latitude
            longitude = newValue.longitude
        }
    }
    //重写计算属性thumbnailURL和imageURL
    override var thumbnailURL: NSURL? { return imageURL }
    override var imageURL: NSURL?  { return links.first?.url } //随便返回一个url
}
