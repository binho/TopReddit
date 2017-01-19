//
//  PostViewModel.swift
//  TopInReddit
//
//  Created by Cleber Santos on 1/17/17.
//  Copyright © 2017 Deviget. All rights reserved.
//

import UIKit

class PostViewModel {
    private(set) var post: Post
    
    init(post: Post) {
        self.post = post
    }
    
    var titleString: String {
        return post.title
    }
    
    // Total comments and upvotes
    var totalCommentsAndUpvotesString: NSAttributedString {
        return NSAttributedString(string: "💬 \(post.totalComments ?? 0)   ⬆️ \(post.totalUpvotes ?? 0)")
    }
    
    // Show author and time ago
    var authorAndTimeAgoString: NSAttributedString {
        let timeAgo = timeAgoSinceDate(date: NSDate(timeIntervalSince1970: post.createdAt), numericDates: true)
        let author = (post.author ?? "Anonymous")
        
        let attributedString = NSMutableAttributedString(string: "\(author) / \(timeAgo)")
        
        let authorRange = (attributedString.string as NSString).range(of: author)
        
        attributedString.addAttribute(NSForegroundColorAttributeName, value: UIColor.black, range: authorRange)
        attributedString.addAttribute(NSFontAttributeName, value: UIFont.boldSystemFont(ofSize: 13), range: authorRange)
        
        return attributedString
    }
    
    func timeAgoSinceDate(date: NSDate, numericDates: Bool) -> String {
        let calendar = NSCalendar.current
        let unitFlags: Set<Calendar.Component> = [.minute, .hour, .day, .weekOfYear, .month, .year, .second]
        let now = NSDate()
        let earliest = now.earlierDate(date as Date)
        let latest = (earliest == now as Date) ? date : now
        let components = calendar.dateComponents(unitFlags, from: earliest as Date,  to: latest as Date)
        
        if (components.year! >= 2) {
            return "\(components.year!) years ago"
        } else if (components.year! >= 1){
            if (numericDates){
                return "1 year ago"
            } else {
                return "Last year"
            }
        } else if (components.month! >= 2) {
            return "\(components.month!) months ago"
        } else if (components.month! >= 1){
            if (numericDates){
                return "1 month ago"
            } else {
                return "Last month"
            }
        } else if (components.weekOfYear! >= 2) {
            return "\(components.weekOfYear!) weeks ago"
        } else if (components.weekOfYear! >= 1){
            if (numericDates){
                return "1 week ago"
            } else {
                return "Last week"
            }
        } else if (components.day! >= 2) {
            return "\(components.day!) days ago"
        } else if (components.day! >= 1){
            if (numericDates){
                return "1 day ago"
            } else {
                return "Yesterday"
            }
        } else if (components.hour! >= 2) {
            return "\(components.hour!) hours ago"
        } else if (components.hour! >= 1){
            if (numericDates){
                return "1 hour ago"
            } else {
                return "An hour ago"
            }
        } else if (components.minute! >= 2) {
            return "\(components.minute!) minutes ago"
        } else if (components.minute! >= 1){
            if (numericDates){
                return "1 minute ago"
            } else {
                return "A minute ago"
            }
        } else if (components.second! >= 3) {
            return "\(components.second!) seconds ago"
        } else {
            return "Just now"
        }
    }
    
}
