//
//  FlickrSearchResponse.swift
//  YapAiTek-Assessment
//
//  Created by tanaz on 9/29/1399 AP.
//

import Foundation
import UIKit

struct FlickrSearchResponse: Codable {

    let photos: Photos?
    let stat: String?

    enum CodingKeys: String, CodingKey {

        case photos = "photos"
        case stat = "stat"
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        photos = try values.decodeIfPresent(Photos.self, forKey: .photos)
        stat = try values.decodeIfPresent(String.self, forKey: .stat)
    }
}

struct Photos: Codable {
    let page: Int?
    let pages: Int?
    let perpage: Int?
    let total: Int?
    let photo: [Photo]?

//    enum CodingKeys: String, CodingKey {
//        case pageNum = "page"
//        case pagesCount = "pages"
//        case perpageCount = "perpage"
//        case totalItem = "total"
//        case photo = "photo"
//    }
//
//    init(from decoder: Decoder) throws {
//        let values = try decoder.container(keyedBy: CodingKeys.self)
//        page = try values.decodeIfPresent(Int.self, forKey: .pageNum)
//        pages = try values.decodeIfPresent(Int.self, forKey: .pagesCount)
//        perpage = try values.decodeIfPresent(Int.self, forKey: .perpageCount)
//        total = try values.decodeIfPresent(Int.self, forKey: .totalItem)
//        photo = try values.decodeIfPresent([Photo].self, forKey: .photo)
//    }

}

struct Photo: Codable {
    let id: String?
    let owner: String?
    let secret: String?
    let server: String?
    let farm: Int?
    let title: String?
    let ispublic: Int?
    let isfriend: Int?
    let isfamily: Int?
    let urlQ: String?

    enum CodingKeys: String, CodingKey {
        case id         = "id"
        case owner      = "owner"
        case secret     = "secret"
        case server     = "server"
        case farm       = "farm"
        case title      = "title"
        case ispublic   = "ispublic"
        case isfriend   = "isfriend"
        case isfamily   = "isfamily"
        case urlQ      = "url_q"
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        id = try values.decodeIfPresent(String.self, forKey: .id)
        owner = try values.decodeIfPresent(String.self, forKey: .owner)
        secret = try values.decodeIfPresent(String.self, forKey: .secret)
        server = try values.decodeIfPresent(String.self, forKey: .server)
        farm = try values.decodeIfPresent(Int.self, forKey: .farm)
        title = try values.decodeIfPresent(String.self, forKey: .title)
        ispublic = try values.decodeIfPresent(Int.self, forKey: .ispublic)
        isfriend = try values.decodeIfPresent(Int.self, forKey: .isfriend)
        isfamily = try values.decodeIfPresent(Int.self, forKey: .isfamily)
        urlQ = try values.decodeIfPresent(String.self, forKey: .urlQ)
    }

}
struct ApiError: Codable {

    let stat: String?
    let code: Int?
    let message: String?

    enum CodingKeys: String, CodingKey {
        case stat = "stat"
        case message = "message"
        case code   = "code"
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        stat = try values.decodeIfPresent(String.self, forKey: .stat)
        code = try values.decodeIfPresent(Int.self, forKey: .code)
        message = try values.decodeIfPresent(String.self, forKey: .message)
    }
}
