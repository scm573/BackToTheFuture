//
//  FlickrApiResponse.swift
//  BackToTheFuture
//
//  Created by Wu, Qifan | Keihan | ECID on 2018/01/27.
//  Copyright © 2018 Wu, Qifan | Keihan | ECID. All rights reserved.
//

import Foundation

struct FlickrApiResponse: Codable {
    let photos: Photos?
    
    struct Photos: Codable {
        let page: Int?
        let pages: Int?
        let perpage: Int?
        let count: String?
        let photo: [Photo]?
        
        struct Photo: Codable {
            let url_m: String?
            let datetaken: String?
            let latitude: String?
            let longitude: String?
        }
    }
}
