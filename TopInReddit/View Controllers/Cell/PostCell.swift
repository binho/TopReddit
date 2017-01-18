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
    
    var hasImage: Bool? = true {
        didSet {
            // Update image height if cell don't have an image
            postImageViewHeightConstraint.constant = (hasImage! ? 182 : 0)
        }
    }
    
    open var delegate: PostCellDelegate?
    
    static let reuseIdentifier = "PostCellIdentifier"
    
    var postViewModel: PostViewModel? {
        didSet {
            guard postViewModel != nil else { return }

            tagLabel.isHidden = (postViewModel!.post.gifImageURL == nil)
            postLabel.text = postViewModel!.titleString
            topLabel.attributedText = postViewModel!.authorAndTimeAgoString
            bottomLabel.attributedText = postViewModel!.totalCommentsAndUpvotesString
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
        imageView?.image = nil
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
        
        // To improve scrolling performance
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
