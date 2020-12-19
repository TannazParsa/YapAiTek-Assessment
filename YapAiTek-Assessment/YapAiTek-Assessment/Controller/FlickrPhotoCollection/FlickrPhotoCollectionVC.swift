//
//  FlickrPhotoCollectionVC.swift
//  YapAiTek-Assessment
//
//  Created by tanaz on 9/29/1399 AP.
//

import Foundation
import UIKit
import RxSwift

class FlickrPhotoCollectionVC: UIViewController {
    
    @IBOutlet weak var collectionView: UICollectionView!
    var bag = DisposeBag()

    private var viewModel : FlickrPhotoCollectionViewModel!
    private let itemsPerRow: CGFloat = 3
    private let sectionInsets = UIEdgeInsets(top: 50.0,
                                             left: 10.0,
                                             bottom: 50.0,
                                             right: 10.0)

    
    override func viewDidLoad() {
        viewModel = FlickrPhotoCollectionViewModel()
        collectionView.register(UINib(nibName: "FlickrPhotoCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "FlickrPhotoCollectionViewCell")
        subscribe()
        viewModel.getPhotoCollection(page: 1)
    }
    
    
    func subscribe() {
       self.viewModel.onChange.subscribe(onNext: { [weak self] state in
           guard let strongSelf = self else {return}
           switch state{
           case .getPhotoCollectionSuccess( _):
            strongSelf.collectionView.reloadData()
           case .getPhotoCollectionFailure( let message):
            strongSelf.showErrorAlert(message: message)
           }
       }).disposed(by: bag)
    }
    
    // MARK: Handle Pagination
    func updateNextSet(){
           print("On Completetion")
        //requests another set of data from the server.
        viewModel.getPhotoCollection(page: viewModel.page + 1)
    }
    
    // MARK: Handle Error
    func showErrorAlert(message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
}

// MARK: UICollectionViewDelegate, UICollectionViewDataSource
extension FlickrPhotoCollectionVC:UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.photos.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "FlickrPhotoCollectionViewCell", for: indexPath) as! FlickrPhotoCollectionViewCell
        cell.config(img: viewModel.photos[indexPath.row])
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let cell = collectionView.cellForItem(at: indexPath) as? FlickrPhotoCollectionViewCell else {
                   return
               }
        cell.flip()
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if indexPath.row == viewModel.photos.count - 6 {
            updateNextSet()
        }
    }
}
extension FlickrPhotoCollectionVC : UICollectionViewDelegateFlowLayout {
    
  func collectionView(_ collectionView: UICollectionView,
                      layout collectionViewLayout: UICollectionViewLayout,
                      sizeForItemAt indexPath: IndexPath) -> CGSize {
    let paddingSpace = sectionInsets.left * (itemsPerRow + 1)
    let availableWidth = view.frame.width - paddingSpace
    let widthPerItem = availableWidth / itemsPerRow
    
    return CGSize(width: widthPerItem, height: widthPerItem)
  }
  
  func collectionView(_ collectionView: UICollectionView,
                      layout collectionViewLayout: UICollectionViewLayout,
                      insetForSectionAt section: Int) -> UIEdgeInsets {
    return sectionInsets
  }
  
  func collectionView(_ collectionView: UICollectionView,
                      layout collectionViewLayout: UICollectionViewLayout,
                      minimumLineSpacingForSectionAt section: Int) -> CGFloat {
    return sectionInsets.left
  }
}
