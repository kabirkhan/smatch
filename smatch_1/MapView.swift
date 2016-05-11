//
//  MapView.swift
//  smatch_1
//
//  Created by Kabir Khan on 5/10/16.
//  Copyright © 2016 Kabir Khan. All rights reserved.
//

import MapKit

func setupMapViewPins(mapView: MKMapView, annotation: MKAnnotation) -> MKAnnotationView? {
    if let annotation = annotation as?  Event {
        let identifier = "pin"
        var view: MKPinAnnotationView
        if let dequeuedView = mapView.dequeueReusableAnnotationViewWithIdentifier(identifier)
            as? MKPinAnnotationView {
            dequeuedView.annotation = annotation as MKAnnotation
            view = dequeuedView
        } else {
            view = MKPinAnnotationView(annotation: annotation as MKAnnotation, reuseIdentifier: identifier)
            view.canShowCallout = true
            view.calloutOffset = CGPoint(x: -5, y: 5)
            view.rightCalloutAccessoryView = UIButton(type: .DetailDisclosure) as UIView
            view.rightCalloutAccessoryView?.tintColor = UIColor.materialMainGreen
        }
        switch annotation.sport {
        case "Basketball":
            view.pinTintColor = UIColor.redColor()
        case "Tennis":
            view.pinTintColor = UIColor.materialMainGreen
        case "Softball":
            view.pinTintColor = UIColor.yellowColor()
        case "Soccer":
            view.pinTintColor = UIColor.cyanColor()
        case "Football":
            view.pinTintColor = UIColor.orangeColor()
        case "Ultimate Frisbee":
            view.pinTintColor = UIColor.purpleColor()
        case "Volleyball":
            view.pinTintColor = UIColor.blueColor()
        default:
            view.pinTintColor = UIColor.grayColor()
        }
        return view
    }
    return nil
}