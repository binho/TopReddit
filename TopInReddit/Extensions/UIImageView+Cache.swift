import Foundation
import UIKit

let imageCache = NSCache<NSString, UIImage>()

extension UIImageView {
    
    enum ImageType: String {
        case normal
        case animated // gif
    }
    
    typealias imageCacheCallback = ((Bool, NSError?) -> ())
    
    func loadImageUsingCacheWithURL(url: URL, type: ImageType, callback: @escaping imageCacheCallback) {
        self.image = nil
        
        // Prefix image cache name with type so we don't override normal and animated
        let cacheKey = NSString(string: "\(type.rawValue)-\(url.lastPathComponent)")
        
        if let cachedImage = imageCache.object(forKey: cacheKey) {
            //print("[\(type.rawValue)] Loaded image from cache: \(cacheKey)")
            
            self.image = cachedImage
            
            callback(true, nil)
            return
        } else {
            URLSession.shared.dataTask(with: url, completionHandler: { (data, response, error) in
                if error != nil {
                    //print(error!)
                    callback(false, error as NSError?)
                } else {
                    DispatchQueue.main.async(execute: { () -> Void in
                        //print("[\(type.rawValue)] Downloaded image and save on cache: \(cacheKey)")
                        
                        if type == .animated {
                            if let animatedImage = UIImage.gif(data: data!) {
                                imageCache.setObject(animatedImage, forKey: cacheKey)
                                self.image = animatedImage
                            }
                        } else if type == .normal {
                            if let normalImage = UIImage(data: data!) {
                                imageCache.setObject(normalImage, forKey: cacheKey)
                                self.image = normalImage
                            }
                        }
                        
                        callback(true, nil)
                    })
                }
            }).resume()
        }
    }
    
}
