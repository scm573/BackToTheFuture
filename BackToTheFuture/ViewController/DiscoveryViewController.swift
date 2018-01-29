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
import CoreData

class DiscoveryViewController: UIViewController {

    @IBOutlet weak var mapView: MKMapView!
    
    let locationManager = CLLocationManager()
    let disposeBag = DisposeBag()
    
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
        locationManager.delegate = self
        if CLLocationManager.authorizationStatus() == .authorizedWhenInUse ||
            CLLocationManager.authorizationStatus() == .authorizedAlways {
            setMap()
        } else {
            locationManager.requestWhenInUseAuthorization()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tabBarController?.tabBar.isHidden = false
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "recordMemorial", let photos = photos {
            let vc = segue.destination as! MemorialViewController
            let view = sender as! MKAnnotationView
            getPhotoInfoFor(view.annotation!, in: photos) { photoUrl, time, lat, lng in
                let memorial = NSEntityDescription.insertNewObject(forEntityName: "Memorial", into: AppDelegate.shared.stack.context) as! Memorial
                memorial.oldPhotoUrl = photoUrl
                memorial.oldPhotoTime = time
                memorial.latitude = lat
                memorial.longitude = lng
                vc.memorial = memorial
            }
        }
    }
    
    @IBAction func refresh(_ sender: Any) {
        SVProgressHUD.show()
        requestBy(mapView.camera.centerCoordinate)
    }
    
    private func requestBy(_ coordinate: CLLocationCoordinate2D) {
        requestPhotosNear(coordinate, pages: pages) { flickrApiResponse in
            performUIUpdatesOnMain {
                SVProgressHUD.dismiss()
                self.photos = flickrApiResponse.photos?.photo
                self.pages = flickrApiResponse.photos?.pages
            }
        }
    }

}

extension DiscoveryViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard let photos = photos else { return nil }
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: "pin") as? MKPinAnnotationView
        if annotationView == nil {
            annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "pin")
            annotationView?.canShowCallout = true

            getPhotoInfoFor(annotation, in: photos) { photoUrl, _, _, _ in
                if let photoUrl = photoUrl {
                    let imageView = UIImageView(frame: CGRect.init(x: 0, y: 0, width: 40, height: 40))
                    imageView.contentMode = .scaleAspectFill
                    imageView.kf.indicatorType = .activity
                    imageView.kf.setImage(with: URL(string: photoUrl))
                    
                    let button = UIButton(frame: CGRect.init(x: 0, y: 0, width: 40, height: 40))
                    button.addSubview(imageView)
                    
                    annotationView?.leftCalloutAccessoryView = button
                }
            }
        } else {
            annotationView?.annotation = annotation
        }
        
        return annotationView
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        performSegue(withIdentifier: "recordMemorial", sender: view)
    }
    
    fileprivate func getPhotoInfoFor(_ annotation: MKAnnotation, in photos: [FlickrApiResponse.Photos.Photo], completionHandler: @escaping((String?, String?, Double, Double) -> Void)) {
        let targetPhoto = photos.first(where: {
            guard let latString = $0.latitude, let lat = Double(latString) else { return false }
            guard let lngString = $0.longitude, let lng = Double(lngString) else { return false }
            return annotation.coordinate.latitude == lat && annotation.coordinate.longitude == lng
        })
        let lat = targetPhoto?.latitude ?? ""
        let lng = targetPhoto?.longitude ?? ""
        completionHandler(targetPhoto?.url_m, targetPhoto?.datetaken, Double(lat)!, Double(lng)!)
    }
}

extension DiscoveryViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .authorizedAlways, .authorizedWhenInUse:
            setMap()
        default:
            locationManager.requestWhenInUseAuthorization()
        }
    }
    
    fileprivate func setMap() {
        SVProgressHUD.show()
        mapView.userLocation.rx
            .observe(CLLocationCoordinate2D.self, "coordinate")
            .filterNil()
            .skip(1) //Skip(0,0)
            .take(1)
            .subscribe(
                onNext: {
                    self.requestBy($0)
                    adjustCameraOf(self.mapView, coordinate: self.mapView.userLocation.coordinate)
                }
            )
            .disposed(by: disposeBag)
    }
}

