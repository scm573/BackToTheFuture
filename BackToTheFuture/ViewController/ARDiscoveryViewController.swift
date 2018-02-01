//
//  ARDiscoveryViewController.swift
//  BackToTheFuture
//
//  Created by Wu, Qifan | Keihan | ECID on 2018/01/31.
//  Copyright © 2018 Wu, Qifan | Keihan | ECID. All rights reserved.
//

import UIKit
import ARCL
import CoreLocation
import Kingfisher

class ARDiscoveryViewController: UIViewController {
    
    var sceneLocationView = SceneLocationView()
    var photos: [FlickrApiResponse.Photos.Photo]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        sceneLocationView.run()
        view.addSubview(sceneLocationView)
        
        let swipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(swipedDown))
        swipeGestureRecognizer.direction = .down
        view.addGestureRecognizer(swipeGestureRecognizer)
        
        photos?.forEach {
            guard let latString = $0.latitude, let lat = Double(latString) else { return }
            guard let lngString = $0.longitude, let lng = Double(lngString) else { return }
            let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: lng)
            let location = CLLocation(coordinate: coordinate, altitude: 300)
            let imageUrl = URL(string: $0.url_m!)
            performUIUpdatesOnMain {
                KingfisherManager.shared.retrieveImage(with: imageUrl!, options: nil, progressBlock: nil) { image, _, _, _ in
                    let annotationNode = LocationAnnotationNode(location: location, image: image!)
                    self.sceneLocationView.addLocationNodeWithConfirmedLocation(locationNode: annotationNode)
                }
            }
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        sceneLocationView.frame = view.bounds
    }
    
    @objc func swipedDown() {
        dismiss(animated: true, completion: nil)
    }
}
