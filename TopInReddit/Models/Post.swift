//
//  Post.swift
//  TopInReddit
//
//  Created by Cleber Santos on 1/17/17.
//  Copyright © 2017 Deviget. All rights reserved.
//

import Foundation

class Post {
    
    var guid: String
    var title: String
    var author: String? = ""
    var totalComments: Int? = 0
    var totalUpvotes: Int? = 0

    var thumbnailURL: URL?
    var mediumImageURL: URL?
    var largeImageURL: URL?
    var gifImageURL: URL? // we just get large size
    
    var permalink: URL?
    
    var createdAt: TimeInterval = 0
    
    init(guid: String, title: String) {
        self.guid = guid
        self.title = title
    }
    
    class func createFromJSON(_ dict: Dictionary<String, AnyObject>) -> Post? {
        if let guid = dict["id"] as? String, let title = dict["title"] as? String {
            let post = Post(guid: guid, title: title)
            
            post.totalComments = (dict["num_comments"] as? Int) ?? 0
            post.totalUpvotes = (dict["ups"] as? Int) ?? 0
            post.createdAt = (dict["created"] as? TimeInterval) ?? 0
            post.author = (dict["author"] as? String) ?? ""
            
            if let permalink = dict["permalink"] as? String {
                post.permalink = URL(string: "https://www.reddit.com/\(permalink)")
            }
            
            // Extract images from dict
            
            if let imagesArray = (dict as NSDictionary).value(forKeyPath: "preview.images") as? NSArray {
                let images = imagesArray.firstObject as! NSDictionary
                
                // Thumb
                if let thumbnailURL = dict["thumbnail"] as? String {
                    post.thumbnailURL = URL(string: thumbnailURL.replacingOccurrences(of: "amp;", with: ""))
                }
                
                // Medium
                if let mediumURL = (images.value(forKeyPath: "resolutions.url") as! NSArray).lastObject as? String {
                    post.mediumImageURL = URL(string: mediumURL.replacingOccurrences(of: "amp;", with: ""))
                }
                
                // Original
                if let sourceURL = images.value(forKeyPath: "source.url").flatMap({ String(describing: $0) }) {
                    post.largeImageURL = URL(string: sourceURL.replacingOccurrences(of: "amp;", with: ""))
                }
                
                // Animated GIF
                if let gifURL = images.value(forKeyPath: "variants.gif.source.url").flatMap({ String(describing: $0) }) {
                    post.gifImageURL = URL(string: gifURL.replacingOccurrences(of: "amp;", with: ""))
                }
            }
            
            return post
        }
        
        return nil
    }
    
}
