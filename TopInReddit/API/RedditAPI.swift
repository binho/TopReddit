//
//  RedditAPI.swift
//  TopInReddit
//
//  Created by Cleber Santos on 1/17/17.
//  Copyright © 2017 Deviget. All rights reserved.
//

import Foundation

class RedditAPI {
    
    // this is the number of cells before reach end of
    // page that we should start loading the next page
    let numberOfItemsBeforeStartLoadingNextPage = 3
    
    private let itemsPerPage = 10
    
    // Store next page for infinite pagination
    private var nextPage: String = ""
    
    func resetPagination() {
        nextPage = ""
    }
    
    func getTopPosts(callback: @escaping APIClient.APICallback) {
        
        let endpoint: String
        if !nextPage.isEmpty {
            endpoint = "https://api.reddit.com/top?after=\(nextPage)&limit=\(itemsPerPage)"
        } else {
            endpoint = "https://api.reddit.com/top?limit=\(itemsPerPage)" // first call
        }
        
        print("Loading endpoint: \(endpoint)")
        
        let api = APIClient()
        api.callEndpoint(endpoint) { (data, error) in
            guard data != nil else {
                callback(nil, nil)
                return
            }
            
            var items = Array<PostViewModel>()
            
            // Try get to get the next page to be loaded in pagination
            if let after = (data as! NSDictionary).value(forKeyPath: "data.after") as? String {
                self.nextPage = after
            }
            
            // Get all childrens from API response
            let childs = (data as! NSDictionary).value(forKeyPath: "data.children") as! NSArray
            
            for child: Dictionary in childs as! [Dictionary<String, AnyObject>] {
                if let itemData = child["data"] as? JSONDictionary {
                    
                    // Try to create post from JSON
                    if let post = Post.createFromJSON(itemData) {
                        let postViewModel = PostViewModel(post: post)
                        
                        items.append(postViewModel)
                    }
                }
            }
            
            callback(items as AnyObject?, nil)
        }
    }
}
