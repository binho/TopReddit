//
//  TopViewController.swift
//  TopInReddit
//
//  Created by Cleber Santos on 1/17/17.
//  Copyright © 2017 Deviget. All rights reserved.
//

import UIKit

class TopViewController: UITableViewController, UISearchBarDelegate, PostCellDelegate {
    
    private let activityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.gray)
    
    // Search/Filter
    private var searchBar: UISearchBar!
    private var searchActive : Bool = false
    private var filteredResults: [PostViewModel] = []
    
    private var results: [PostViewModel] = []
    
    let api = RedditAPI()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        loadData()
    }
    
    func loadData() {
        /*
        if api.nextPage.isEmpty {
            self.results.removeAll()
        }*/
        
        activityIndicatorView.startAnimating()

        api.getTopPosts() { (data, error) in
            self.results.append(contentsOf: (data as! [PostViewModel]))
            
            DispatchQueue.main.async {
                self.refreshControl?.endRefreshing()
                self.activityIndicatorView.stopAnimating()
                self.tableView.reloadData()
            }
        }
    }
    
    func refreshData(sender: AnyObject) {
        api.resetPagination()
        
        // Remove all stored
        results.removeAll()
        filteredResults.removeAll()
        
        loadData()
    }
    
    func setupUI() {
        self.title = "Top Reddit"

        // Setup search bar
        searchBar = UISearchBar(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: 40))
        searchBar.searchBarStyle = .minimal
        searchBar.placeholder = "Filter posts"
        searchBar.delegate = self
        tableView.tableHeaderView = searchBar
        tableView.tableFooterView = UIView(frame: .zero)
        
        // Setup activity indicator view
        activityIndicatorView.hidesWhenStopped = true
        activityIndicatorView.center = CGPoint(x: self.view.frame.size.width/2, y: self.view.frame.size.height/2 - 60)
        self.view.addSubview(activityIndicatorView)
        self.view.bringSubview(toFront: activityIndicatorView)
        
        // Setup pull to refresh
        self.refreshControl?.addTarget(self, action: #selector(refreshData(sender:)), for: .valueChanged)
        
        tableView.separatorStyle = .none
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 305
    }
    
    // MARK: - Table View

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (searchActive ? filteredResults.count : results.count)
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: PostCell.reuseIdentifier, for: indexPath) as! PostCell
        cell.delegate = self

        let postViewModel = (searchActive ? filteredResults[indexPath.row] : results[indexPath.row])
        
        cell.hasImage = postViewModel.post.mediumImageURL != nil
        
        cell.postViewModel = postViewModel
        
        cell.postImageView.image = nil
        if let imageURL = postViewModel.post.mediumImageURL {
            cell.postImageView.loadImageUsingCacheWithURL(url: imageURL, type: .normal) { (success, error) in
                if error != nil {
                    print("Cell image error: \(error)")
                }
            }
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row == (results.count - api.numberOfItemsBeforeStartLoadingNextPage) && !searchActive {
            print("Loading more content... total loaded: \(results.count)")
            self.loadData()
        }
    }
    
    // MARK: - UIScrollViewDelegate
    
    override func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        // If search is first response lets remove focus when start scrolling
        if self.searchBar.isFirstResponder {
            self.view.endEditing(true)
        }
    }
    
    // MARK: - UISearchBarDelegate
    
    func searchBarDismiss() {
        searchActive = false
        filteredResults.removeAll()
        
        DispatchQueue.main.async {
            self.searchBar.resignFirstResponder()
        }
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchActive = true
        filteredResults = results
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        searchBarDismiss()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBarDismiss()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBarDismiss()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        filteredResults = results.filter({ (postViewModel) -> Bool in
            let tmp: NSString = postViewModel.post.title as NSString
            let range = tmp.range(of: searchText, options: NSString.CompareOptions.caseInsensitive)
            return range.location != NSNotFound
        })
        
        searchActive = filteredResults.count > 0
        
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
    // MARK: PostCellDelegate
    
    func postCell(_ cell: PostCell, didTapPost postViewModel: PostViewModel) {
        self.performSegue(withIdentifier: "detailSegue", sender: postViewModel)
    }
    
    func postCell(_ cell: PostCell, didTapToOpenInSafari postViewModel: PostViewModel) {
        if let permalink = postViewModel.post.permalink {
            UIApplication.shared.open(permalink, options: [:], completionHandler: { (success) in
                print("Open \(permalink.absoluteString): \(success)")
            })
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "detailSegue" {
            // Pass selected `PostViewModel` to detail view controller
            if let localPostViewModel = sender as? PostViewModel {
                let viewController = (segue.destination as! DetailViewController)
                viewController.postViewModel = localPostViewModel
            }
        }
    }

}
