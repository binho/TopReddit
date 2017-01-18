//
//  PostCell.swift
//  TopInReddit
//
//  Created by Cleber Santos on 1/17/17.
//  Copyright © 2017 Deviget. All rights reserved.
//

import UIKit

protocol PostCellDelegate {
    func postCell(_ cell: PostCell, didTapPost postViewModel: PostViewModel)
    func postCell(_ cell: PostCell, didTapToOpenInSafari postViewModel: PostViewModel)
}

class PostCell: UITableViewCell {
    
    open var delegate: PostCellDelegate?
    
    static let reuseIdentifier = "PostCellIdentifier"
    
    var postViewModel: PostViewModel? {
        didSet {
            guard postViewModel != nil else { return }

            if postViewModel!.post.gifImageURL != nil {
                tagLabel.isHidden = false
            }
            
            self.postLabel.text = postViewModel!.titleString
            self.topLabel.attributedText = postViewModel!.authorAndTimeAgoString
            self.bottomLabel.attributedText = postViewModel!.totalCommentsAndUpvotesString
            
            if let imageURL = postViewModel!.post.mediumImageURL {
                self.postImageView.loadImageUsingCacheWithURL(url: imageURL, type: .normal) { (success, error) in
                    print(success)
                }
            }
        }
    }
    
    @IBOutlet weak var topLabel: UILabel!
    @IBOutlet weak var postLabel: UILabel!
    @IBOutlet weak var postImageView: UIImageView!
    @IBOutlet weak var tagLabel: UILabel!
    @IBOutlet weak var postImageViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var bottomLabel: UILabel!
    @IBOutlet weak var bottomButton: UIButton!
    
    override func prepareForReuse() {
        tagLabel.isHidden = true
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        tagLabel.layer.cornerRadius = 10
        tagLabel.layer.masksToBounds = true
    }
    
    override func awakeFromNib() {
        self.separatorInset = .zero
        self.selectionStyle = .none
        
        // Improves scrolling performance
        postImageView.layer.shouldRasterize = true
        postImageView.layer.rasterizationScale = UIScreen.main.scale
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(imageViewTapped))
        postImageView.addGestureRecognizer(tapGesture)
        postImageView.isUserInteractionEnabled = true
    }
    
    @IBAction func bottomButtonTapped(_ sender: Any) {
        if postViewModel != nil {
            delegate?.postCell(self, didTapToOpenInSafari: postViewModel!)
        }
    }

    func imageViewTapped() {
        if postViewModel != nil {
            delegate?.postCell(self, didTapPost: postViewModel!)
        }
    }

}
