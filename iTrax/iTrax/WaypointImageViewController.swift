//
//  WaypointImageViewController.swift
//  iTrax
//
//  Created by Niu Panfeng on 05/01/2017.
//  Copyright © 2017 NaPaFeng. All rights reserved.
//

import UIKit

class WaypointImageViewController: ImageViewController {
    
    private struct Constants {
        static let EmbedMapSegue = "Embed Map"
    }
    
    var waypoint: GPX.Waypoint? {
        didSet {
            imageURL = waypoint?.imageURL
            title = waypoint?.name
            updateEmbeddedMap()
        }
    }
    private func updateEmbeddedMap() {
        if let mapView = smvc?.mapView {
            mapView.mapType = .Standard
            mapView.removeAnnotations(mapView.annotations)
            if let wp = waypoint{
                mapView.addAnnotation(wp)
                mapView.showAnnotations(mapView.annotations, animated: true)
            }
        }
    }
    // MARK: - SimpeMapViewContrller
    var smvc: SimpleMapViewController?
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == Constants.EmbedMapSegue {
            smvc = segue.destinationViewController as? SimpleMapViewController
            updateEmbeddedMap()
        }
    }
   
}
