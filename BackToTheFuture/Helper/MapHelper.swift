//
//  MapHelper.swift
//  BackToTheFuture
//
//  Created by Wu, Qifan | Keihan | ECID on 2018/01/27.
//  Copyright © 2018 Wu, Qifan | Keihan | ECID. All rights reserved.
//

import MapKit

class MapHelper {

    static func adjustCameraOf(_ mapView: MKMapView, coordinate: CLLocationCoordinate2D) {
        let regionRadius: CLLocationDistance = 10000
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(coordinate, regionRadius * 2.0, regionRadius * 2.0)
        mapView.setRegion(coordinateRegion, animated: true)
    }

    static func addPinTo(_ mapView: MKMapView, coordinate: CLLocationCoordinate2D, title: String?) {
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinate
        if let title = title {
            annotation.title = title
        }
        mapView.addAnnotation(annotation)
    }

    static func removeAllAnnotationsFrom(_ mapView: MKMapView) {
        if mapView.annotations.isEmpty { return }
        for annotation in mapView.annotations {
            mapView.removeAnnotation(annotation)
        }
    }

}
