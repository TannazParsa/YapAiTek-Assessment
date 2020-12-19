//
//  FlickrServices.swift
//  YapAiTek-Assessment
//
//  Created by tanaz on 9/29/1399 AP.
//

import Foundation
import UIKit
import RxSwift
import RxCocoa
import Alamofire

struct FlickrServices {
    
    static let shared = FlickrServices()
    
    func getSearchPhotos(page:Int,consumerKey: String) -> Observable<Result<FlickrSearchResponse>>  {
        let parameters :Dictionary = [
            "method"         : "flickr.photos.getRecent",
            "api_key"        : consumerKey,
            "format"         : "json",
            "nojsoncallback" : "1",
            "extras"         : "url_q,url_z",
            "page"           : page
        ] as [String : Any]
        return WebServices.shared.request(url: "https://api.flickr.com/services/rest/",
                                          param: parameters,
                                          method: .get,
                                          encoding: URLEncoding.default)
       
    }
}
