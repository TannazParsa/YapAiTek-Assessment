//
//  FlickrPhotoCollectionViewCell.swift
//  YapAiTek-Assessment
//
//  Created by tanaz on 9/29/1399 AP.
//

import UIKit
import Kingfisher
class FlickrPhotoCollectionViewCell: UICollectionViewCell {

    
    @IBOutlet weak var lblOwner: UILabel!
    @IBOutlet weak var lbltitle: UILabel!
    @IBOutlet weak var detailsView: UIView!
    @IBOutlet weak var imgFlickr: UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        detailsView.isHidden = true
    }
    
    func config(img:Photo) {
        detailsView.isHidden = true

        lbltitle.text = img.title
        lblOwner.text = img.owner
        if let imgURL = URL(string: img.url_q ?? "") {
            imgFlickr.kf.setImage(with: imgURL, placeholder: UIImage(), options: [.transition(.fade(0.1))])
        }
    }
    
    func flip() {
            let flipSide: UIView.AnimationOptions = detailsView.isHidden ? .transitionFlipFromLeft : .transitionFlipFromRight
            UIView.transition(with: self.contentView, duration: 0.3, options: flipSide, animations: { [weak self]  () -> Void in
                self?.imgFlickr.isHidden = !(self?.imgFlickr.isHidden ?? true)
                self?.detailsView.isHidden = !(self?.detailsView.isHidden ?? false)
            }, completion: nil)
        }

}
