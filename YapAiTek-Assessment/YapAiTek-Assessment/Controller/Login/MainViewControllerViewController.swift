//
//  ViewController.swift
//  YapAiTek-Assessment
//
//  Created by tanaz on 9/28/1399 AP.
//

import UIKit
import OAuthSwift
import SafariServices
import RxSwift

class MainViewController: OAuthViewController {

    var bag = DisposeBag()

    @IBOutlet weak var loginWithFlickr: UIButton!

    var currentParameters = [String: String]()
    private var viewModel: MainViewModel!

    lazy var internalWebViewController: WebViewController = {
        let controller = WebViewController()
        controller.view = UIView(frame: UIScreen.main.bounds) // loaded from storyboard
        controller.delegate = self
        controller.viewDidLoad() // allow WebViewController to use this ViewController as parent to be presented
        return controller
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel = MainViewModel(self)
        currentParameters["consumerKey"] = Constants.shared.apiKey
        currentParameters["consumerSecret"] = Constants.shared.secretKey
        bindActions()
        subscribe()

    }

    // MARK: Handle Error
    func showErrorAlert(message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }

    func bindActions() {
        loginWithFlickr.rx.tap.throttle(.microseconds(100), scheduler: MainScheduler.instance).subscribe(onNext: { [weak self] _ in
            guard let strongSelf = self else {return}
            strongSelf.viewModel.doOAuthFlickr(strongSelf.currentParameters)
            }).disposed(by: bag)
    }

     func subscribe() {
        self.viewModel.onChange.subscribe(onNext: { [weak self] state in
            guard let strongSelf = self else {return}
            switch state {
            case .loginSuccess(let oauth, let credential):
                print(oauth)
                print(credential)
                let mainStoryboard = UIStoryboard(name: "Main", bundle: nil)
                let vc = mainStoryboard.instantiateViewController(withIdentifier: "FlickrPhotoCollectionVC") as! FlickrPhotoCollectionVC
                strongSelf.navigationController?.pushViewController(vc, animated: true)
            case .loginFailed( let message):
                strongSelf.showErrorAlert(message: message)
                print(message)
            }
        }).disposed(by: bag)
     }

    // MARK: handler
    func getURLHandler() -> OAuthSwiftURLHandlerType {
        return internalWebViewController
    }

}
extension MainViewController: OAuthWebViewControllerDelegate {
    func oauthWebViewControllerDidPresent() {

    }

    func oauthWebViewControllerDidDismiss() {

    }

    func oauthWebViewControllerWillAppear() {

    }

    func oauthWebViewControllerDidAppear() {

    }

    func oauthWebViewControllerWillDisappear() {

    }

    func oauthWebViewControllerDidDisappear() {

    }
}
