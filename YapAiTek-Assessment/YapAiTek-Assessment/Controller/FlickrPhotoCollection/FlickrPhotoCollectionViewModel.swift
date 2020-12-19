//
//  FlickrPhotoCollectionViewModel.swift
//  YapAiTek-Assessment
//
//  Created by tanaz on 9/29/1399 AP.
//

import Foundation
import RxCocoa
import RxSwift

class FlickrPhotoCollectionViewModel {
    
    var onChange = PublishSubject<State>()
    var bag = DisposeBag()
    var page = 1
    var photos = [Photo]()

    enum State {
        case getPhotoCollectionSuccess(list:FlickrSearchResponse)
        case getPhotoCollectionFailure(message: String)
    }
    
    func getPhotoCollection(page:Int) {
        FlickrServices.shared.getSearchPhotos(page:page,consumerKey:Constants.shared.api_key).subscribe(onNext: { [weak self] (result) in
        guard let strongSelf = self else {return}
        switch result {
        case .success(let value) :
            print(value)
            if let response = value as? FlickrSearchResponse {
                strongSelf.photos.append(contentsOf: response.photos?.photo ?? [])
                strongSelf.onChange.onNext(.getPhotoCollectionSuccess(list: response))
            }
        case .failure(let value) :
            print(value)
        }
    
        }).disposed(by: self.bag)
    }
}
