//
//  ViewController.swift
//  iTrax
//
//  Created by Niu Panfeng on 29/12/2016.
//  Copyright © 2016 NaPaFeng. All rights reserved.
//

import UIKit
import MapKit

class GPXViewController: UIViewController, MKMapViewDelegate {

    // MARK: - Notification
    // 消息观察者
    weak var nameObserver: NSObjectProtocol?
    /** 视图控制器生命周期：viewDidLoad */
    override func viewDidLoad() {
        super.viewDidLoad()
        nameObserver = createObserver()
    }
    /** 创建nameObserver,接收Notification（含有NSURL信息) */
    private func createObserver() -> NSObjectProtocol  {
        let center = NSNotificationCenter.defaultCenter()
        let appDelegate = UIApplication.sharedApplication().delegate
        let queue = NSOperationQueue.mainQueue()
        let notificationObserver = center.addObserverForName(GPXURL.NotificationName, object: appDelegate, queue: queue) { notification -> Void in
            if let url = notification.userInfo?[GPXURL.Key] as? NSURL {
                self.gpxURL = url
            }
        }
        return notificationObserver
    }
    /** 移除nameObserver */
    deinit {
        if let nameObserver = nameObserver {
            NSNotificationCenter.defaultCenter().removeObserver(nameObserver) // 那我们就把它释放掉好了
        }
    }
    
    
    // MARK: - MapView
    // 故事板接口mapView
    @IBOutlet weak var mapView: MKMapView! {
        didSet{
            mapView.mapType = .Standard //.Satellite
            mapView.delegate = self
        }
    }
    // URL链接
    var gpxURL: NSURL? {
        didSet {
            clearWaypoints()   //先清除
            if let url = gpxURL {
                GPX.parse(url) { (gpxParsed:GPX?) -> Void in
                    if let gpx = gpxParsed {
                        self.handleWaypoints(gpx.waypoints)
                    }
                }
            }
        }
    }
    /** 清除Waypoints */
    private func clearWaypoints() {
        if mapView?.annotations != nil {
            mapView.removeAnnotations(mapView.annotations)
        }
    }
    /** 处理Waypoints */
    private func handleWaypoints(waypoints: [GPX.Waypoint]) {
        mapView.addAnnotations(waypoints)
        mapView.showAnnotations(waypoints, animated: true)
    }
    
    
    // MARK: - MKMapViewDelegate
    // 常量
    private struct Constants {
        static let PartialTrackColor = UIColor.greenColor()
        static let FullTrackColor = UIColor.blackColor()
        static let TrackLineWidth: CGFloat = 3.0
        static let ZoomCooldown = 1.5
        static let LeftCalloutFrame = CGRect(x: 0, y: 0, width: 59, height: 59)
        static let AnnotationViewReuseIdentifier = "waypoints"
        static let ShowImageSegue = "Show Image"
    }
    /** 自定义MKAnnotationView */
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        // 默认的MKAnnotationView（如果不写，系统也会默认为你写上）
        var view = mapView.dequeueReusableAnnotationViewWithIdentifier(Constants.AnnotationViewReuseIdentifier)
        if view == nil {
            view = MKPinAnnotationView(annotation: annotation, reuseIdentifier: Constants.AnnotationViewReuseIdentifier)
            view?.canShowCallout = true
        } else {
            view?.annotation = annotation
        }
        
        //先将CalloutAccessoryView置空，再赋值
        //leftCalloutAccessoryView,rightCalloutAccessoryView都是MKAnnotation的子视图
        view?.leftCalloutAccessoryView = nil
        view?.rightCalloutAccessoryView = nil
        if let waypoint = annotation as? GPX.Waypoint {
            if waypoint.thumbnailURL != nil {
                //leftCalloutAccessoryView在被点击选中之后加载图片，因为annotationView可能永远不会被用户点击
                view?.leftCalloutAccessoryView = UIImageView(frame: Constants.LeftCalloutFrame)
            }
            if waypoint.imageURL != nil {
                view?.rightCalloutAccessoryView = UIButton(type: UIButtonType.DetailDisclosure) as UIButton
            }
        }
        
        return view
    }
    /** didSelectAnnotationView，加载leftCalloutAccessoryView */
    func mapView(mapView: MKMapView, didSelectAnnotationView view: MKAnnotationView) {
        if let waypoint = view.annotation as? GPX.Waypoint { // MKAnnotationView->GPX.Waypoint
            if let thumbnailImageView = view.leftCalloutAccessoryView as? UIImageView {//UIView->UIImageView
                if let imageData = NSData(contentsOfURL: waypoint.thumbnailURL!) {//获取imageData
                    if let image = UIImage(data: imageData) { //imageData->iamge
                        thumbnailImageView.image = image
                    }
                }
            }
        }
    }
    /** calloutAccessoryControlTapped，从rightCalloutAccessoryView跳转 */
    func mapView(mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        performSegueWithIdentifier(Constants.ShowImageSegue, sender: view)
    }
    /** prepareForSegue */
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == Constants.ShowImageSegue {
            if let waypoint = (sender as? MKAnnotationView)?.annotation as? GPX.Waypoint {
                if let ivc = segue.destinationViewController as? ImageViewController {
                    ivc.imageURL = waypoint.imageURL
                    ivc.title = waypoint.name
                }
            }
        }
    }
}

