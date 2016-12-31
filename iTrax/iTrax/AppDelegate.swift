//
//  AppDelegate.swift
//  iTrax
//
//  Created by Niu Panfeng on 29/12/2016.
//  Copyright © 2016 NaPaFeng. All rights reserved.
//

import UIKit

struct GPXURL {
    static let NotificationRadioStationName = "GPXURL Radio Station"
    static let Key = "GPXURL URL Key"
    static let defaultURL = NSURL(string: "http://web.stanford.edu/class/cs193p/Vacation.gpx")!
}

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    // AirDrop接受到文件（处理NSURL资源）时调用，true表示处理完毕
    func application(app: UIApplication, openURL url: NSURL, options: [String : AnyObject]) -> Bool {
        print("url = \(url)")
        broadcastGPXURLNotification(url: url)
        return true
    }

    // applicationDidBecomeActive
    func applicationDidBecomeActive(application: UIApplication) {
        broadcastGPXURLNotification(url: GPXURL.defaultURL)
    }
    
    // AppDelegate广播一个有NSURL信息的Notification
    private func broadcastGPXURLNotification(url url: NSURL) {
        let center = NSNotificationCenter.defaultCenter()
        let notification = NSNotification(name: GPXURL.NotificationRadioStationName, object: self, userInfo: [GPXURL.Key : url ])
        center.postNotification(notification)
    }
    

    


}

