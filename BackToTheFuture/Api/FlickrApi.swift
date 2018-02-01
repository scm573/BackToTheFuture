//
//  FlickrApi.swift
//  BackToTheFuture
//
//  Created by Wu, Qifan | Keihan | ECID on 2018/01/27.
//  Copyright © 2018 Wu, Qifan | Keihan | ECID. All rights reserved.
//

import Foundation
import CoreLocation
import SVProgressHUD

class FlickrApi {

    static func requestPhotosNear(_ coordinate: CLLocationCoordinate2D, pages: Int?, completionHandler: @escaping((FlickrApiResponse) -> Void)) {
        if !ReachabilityHelper.isNetworkConnected() {
            AlertHelper.presentAlert(title: "Network error", message: "No network connection.", preferredStyle: .alert, actionTitle: "Try again")
            return
        }
        let imageNumPerPage = 50
        let page = pages == nil ? 1 : arc4random_uniform(UInt32(min(pages!, 4000/imageNumPerPage)))
        let request = URLRequest(url: URL(string: "https://api.flickr.com/services/rest/?method=flickr.photos.search&api_key=15b9dff955bafd96df4e7d92632494fb&lat=\(coordinate.latitude)&lon=\(coordinate.longitude)&extras=url_m%2C+date_taken%2C+geo&per_page=\(imageNumPerPage)&page=\(page)&format=json&nojsoncallback=1")!)
        let session = URLSession.shared
        let task = session.dataTask(with: request) { data, response, error in
            SVProgressHUD.dismiss()
            if let httpResponse = response as? HTTPURLResponse {
                if 400...599 ~= httpResponse.statusCode {
                    AlertHelper.presentAlert(title: "Server error", message: "Something exploded.", preferredStyle: .alert, actionTitle: "Try again")
                    return
                }
            }
            if error != nil {
                AlertHelper.presentAlert(title: "Network error", message: error?.localizedDescription ?? "", preferredStyle: .alert, actionTitle: "Try again")
                return
            }
            
            let decoder: JSONDecoder = JSONDecoder()
            do {
                let flickrApiResponse: FlickrApiResponse = try decoder.decode(FlickrApiResponse.self, from: data!)
                completionHandler(flickrApiResponse)
            } catch {
                AlertHelper.presentAlert(title: "Server error", message: "Something exploded.", preferredStyle: .alert, actionTitle: "Try again")
            }
        }
        SVProgressHUD.show()
        task.resume()
    }

}
