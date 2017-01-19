//
//  DetailViewController.swift
//  TopInReddit
//
//  Created by Cleber Santos on 1/18/17.
//  Copyright © 2017 Deviget. All rights reserved.
//

import UIKit
import Photos

class DetailViewController: UIViewController {
    
    var postViewModel: PostViewModel?
    
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var bottomLabel: UILabel!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var activityIndicatorView: UIActivityIndicatorView!
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupUI()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        //  Check for connection status
        guard InternetManager.isConnected() else {
            InternetManager.showInternetRequiredMessageInViewController(self)
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                self.activityIndicatorView.stopAnimating()
            }
            return
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        saveButton.layer.cornerRadius = 15
        saveButton.layer.masksToBounds = true
        
        closeButton.backgroundColor = UIColor(hexString: "e5e5e5")
        closeButton.layer.cornerRadius = 20
        closeButton.layer.masksToBounds = true
    }
    
    func startedLoadingImage() {
        DispatchQueue.main.async {
            self.activityIndicatorView.startAnimating()
            self.saveButton.isEnabled = false
            self.saveButton.alpha = 0.4
        }
    }
    
    func finishedLoadingImageWithSuccess(_ success: Bool) {
        DispatchQueue.main.async {
            self.activityIndicatorView.stopAnimating()
            self.saveButton.isEnabled = success
            self.saveButton.alpha = (success ? 1.0 : 0.4)
            
            // When we finish loading do a quick animation on save button to trigger user atention
            if (success) {
                self.saveButton.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
                UIView.animate(withDuration: 1.5, delay: 0, usingSpringWithDamping: 0.2, initialSpringVelocity: 6.0, options: .allowUserInteraction, animations: { [weak self] in
                    self?.saveButton.transform = CGAffineTransform.identity
                }, completion: nil)
            }
        }
    }
    
    func setupUI() {
        self.view.backgroundColor = UIColor.white
        imageView.contentMode = .scaleAspectFit

        bottomLabel.attributedText = postViewModel?.totalCommentsAndUpvotesString
        
        // Load image
        startedLoadingImage()
        if let gifImageURL = postViewModel?.post.gifImageURL {
            imageView.loadImageUsingCacheWithURL(url: gifImageURL, type: .animated) { (success, error) in
                self.finishedLoadingImageWithSuccess(success)
            }
        } else if let largeImageURL = postViewModel?.post.largeImageURL {
            imageView.loadImageUsingCacheWithURL(url: largeImageURL, type: .normal) { (success, error) in
                self.finishedLoadingImageWithSuccess(success)
            }
        }
    }
    
    @IBAction func closeButtonTapped(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func saveButtonTapped(_ sender: Any) {
        // Check permissions before trying to save
        let status = PHPhotoLibrary.authorizationStatus()
        
        if status == PHAuthorizationStatus.authorized {
            saveCurrentImage()
        } else if status == PHAuthorizationStatus.denied {
            showPermissionRequiredAlert()
        } else if status == PHAuthorizationStatus.notDetermined {
            PHPhotoLibrary.requestAuthorization({ (newStatus) in
                if newStatus == PHAuthorizationStatus.authorized {
                    self.saveCurrentImage()
                } else {
                    self.showPermissionRequiredAlert()
                }
            })
        }
    }
    
    // MARK: Save image
    
    func saveCurrentImage() {
        // Try to save GIF first, then check for normal image
        let imageData: Data?
        if let gifImageURL = postViewModel?.post.gifImageURL {
            imageData = try! Data(contentsOf: gifImageURL)
        } else {
            imageData = UIImagePNGRepresentation(imageView.image!)
        }
        
        if imageData != nil {
            PHPhotoLibrary.shared().performChanges({
                PHAssetCreationRequest.forAsset().addResource(with: .photo, data: imageData!, options: nil)
            }) { (success, error) in
                if error != nil {
                    self.showAlert(title: "Error", message: error!.localizedDescription)
                } else {
                    self.showAlert(title: "Saved", message: "Image saved with success!")
                }
            }
        } else {
            self.showAlert(title: "Error", message: "Can't load image data")
        }
    }

    // MARK: Alerts
    
    func showPermissionRequiredAlert() {
        showAlert(title: "Permission Required", message: "Please allow permissions to save on Photo Album.")
    }
    
    func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
}
