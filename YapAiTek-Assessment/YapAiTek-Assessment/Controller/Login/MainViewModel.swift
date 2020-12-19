//
//  MainViewModel.swift
//  YapAiTek-Assessment
//
//  Created by tanaz on 9/29/1399 AP.
//

import Foundation
import RxSwift
import OAuthSwift


class MainViewModel {
    
    var oauthswift: OAuthSwift?
    var vc: MainViewController!
    var onChange = PublishSubject<State>()
    
    enum State {
        case loginSuccess(OAuth:OAuth1Swift,credential:OAuthSwiftCredential)
        case loginFailed(message: String)
    }
    
    init(_ vc:MainViewController) {
        self.vc = vc
    }
    
    // MARK: Flickr
    func doOAuthFlickr(_ serviceParameters: [String:String]) {

        let oauthswift = OAuth1Swift(
            consumerKey:    serviceParameters["consumerKey"]!,
            consumerSecret: serviceParameters["consumerSecret"]!,
            requestTokenUrl: Constants.shared.requestTokenUrl,
            authorizeUrl:    Constants.shared.authorizeUrl,
            accessTokenUrl:  Constants.shared.accessTokenUrl
        )
        self.oauthswift = oauthswift
        oauthswift.authorizeURLHandler = vc.getURLHandler()
        let _ = oauthswift.authorize(
        withCallbackURL: URL(string: "oauth-swift://oauth-callback/flickr")!) { result in
            switch result {
            case .success(let (credential, _, _)):
                print(credential)
                self.onChange.onNext(.loginSuccess(OAuth:oauthswift, credential: credential))
            case .failure(let error):
                print(error.description)
                self.onChange.onNext(.loginFailed(message: error.description))

            }
        }
    }
    
   
}
