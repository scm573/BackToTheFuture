//
//  ViewController.swift
//  BackToTheFuture
//
//  Created by Wu, Qifan | Keihan | ECID on 2018/01/26.
//  Copyright © 2018 Wu, Qifan | Keihan | ECID. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import RxOptional
import CoreLocation
import MapKit
import SVProgressHUD
import Kingfisher
import ARCL

class DiscoveryViewController: UIViewController {

    @IBOutlet weak var mapView: MKMapView!
    
    let dispostBag = DisposeBag()
    
    var pages: Int?
    var photos: [FlickrApiResponse.Photos.Photo]? {
        didSet {
            performUIUpdatesOnMain {
                removeAllAnnotationsFrom(self.mapView)
                self.photos?.forEach {
                    guard let latString = $0.latitude, let lat = Double(latString) else { return }
                    guard let lngString = $0.longitude, let lng = Double(lngString) else { return }
                    addPinTo(self.mapView, coordinate: CLLocationCoordinate2D(latitude: lat, longitude: lng), title: $0.datetaken)
                }
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        SVProgressHUD.show()

        mapView.userLocation.rx
            .observe(CLLocationCoordinate2D.self, "coordinate")
            .filterNil()
            .skip(1)
            .take(1)
            .subscribe(
                onNext: {
                    self.requestBy($0)
                    SVProgressHUD.dismiss()
                    adjustCameraOf(self.mapView, coordinate: self.mapView.userLocation.coordinate)
                }
            )
            .disposed(by: dispostBag)
    }
    
    @IBAction func refresh(_ sender: Any) {
        requestBy(mapView.camera.centerCoordinate)
    }
    
    func requestBy(_ coordinate: CLLocationCoordinate2D) {
        requestPhotosNear(coordinate, pages: pages) { flickrApiResponse in
            self.photos = flickrApiResponse.photos?.photo
            self.pages = flickrApiResponse.photos?.pages
        }
    }

}

extension DiscoveryViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard let photos = photos else { return nil }
        var annotationView:MKPinAnnotationView? = mapView.dequeueReusableAnnotationView(withIdentifier: "pin") as? MKPinAnnotationView
        if annotationView == nil {
            annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "pin")
            annotationView?.canShowCallout = true
        } else {
            annotationView?.annotation = annotation
        }
        
        let imageUrl = photos.first(where: {
            guard let latString = $0.latitude, let lat = Double(latString) else { return false }
            guard let lngString = $0.longitude, let lng = Double(lngString) else { return false }
            return annotation.coordinate.latitude == lat && annotation.coordinate.longitude == lng
        })?.url_m
        if let imageUrl = imageUrl {
            let imageView = UIImageView(frame: CGRect.init(x: 0, y: 0, width: 40, height: 40))
            imageView.contentMode = .scaleAspectFill
            imageView.kf.indicatorType = .activity
            imageView.kf.setImage(with: URL(string: imageUrl))
            annotationView?.leftCalloutAccessoryView = imageView
        }
        
        return annotationView
    }
}

