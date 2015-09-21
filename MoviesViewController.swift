//
//  MoviesViewController.swift
//  RottenTomatoes
//
//  Created by Matthew Goo on 9/15/15.
//  Copyright © 2015 mattgoo. All rights reserved.
//

import UIKit
import AFNetworking
import MBProgressHUD

class MoviesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UITabBarDelegate, UISearchBarDelegate, UICollectionViewDataSource, UICollectionViewDelegate {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var errorAlertView: UIView!
    @IBOutlet weak var categoryTabBar: UITabBar!
    @IBOutlet weak var boxOfficeTabBarItem: UITabBarItem!
    @IBOutlet weak var dvdTabBarItem: UITabBarItem!
    @IBOutlet weak var navigationBarItem: UINavigationItem!
    @IBOutlet weak var movieSearchBar: UISearchBar!
    @IBOutlet weak var gridOrListViewSegmentedControl: UISegmentedControl!
    @IBOutlet weak var movieGridView: UICollectionView!
    
    
    var movies: [NSDictionary]?
    var filteredMovies: [NSDictionary]?
    var refreshControl: UIRefreshControl!
    var originTableViewOriginY: CGFloat!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let URLCache = NSURLCache(memoryCapacity: 4 * 1024 * 1024, diskCapacity: 20 * 1024 * 1024, diskPath: nil)
        NSURLCache.setSharedURLCache(URLCache)
        gridOrListViewSegmentedControl.selectedSegmentIndex = 0
//        NSURLCacheStoragePolicy = NSURLRequestReturnCacheDataElseLoad
        
        tableView.dataSource = self
        tableView.delegate = self
        movieGridView.delegate = self
        movieGridView.dataSource = self
        categoryTabBar.delegate = self
        movieSearchBar.delegate = self
        
        originTableViewOriginY = tableView.frame.origin.y
        categoryTabBar.selectedItem = boxOfficeTabBarItem
        
        fetchMovies()
        
        refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: "onRefresh", forControlEvents: UIControlEvents.ValueChanged)
        self.tableView.insertSubview(refreshControl, atIndex: 0)
        
    }
    
    @IBAction func onChangeGridOrList(sender: AnyObject) {
        if gridOrListViewSegmentedControl.selectedSegmentIndex == 1 {
            movieGridView.hidden = false
        } else {
            movieGridView.hidden = true
        }
    }
    
    func tabBar(tabBar: UITabBar, didSelectItem item: UITabBarItem) {
        let currentTabItem = categoryTabBar.selectedItem
        if currentTabItem == dvdTabBarItem {
            navigationBarItem.title = "Top DVD Rentals"
        } else {
            navigationBarItem.title = "Box Office"
        }
        fetchMovies()
    }
    
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        if let movies = movies {
            filteredMovies = searchText.isEmpty ? movies : movies.filter({(movie: NSDictionary) -> Bool in
                let title = movie["title"] as? String
                return title!.rangeOfString(searchText, options: .CaseInsensitiveSearch) != nil
            })
            
            tableView.reloadData()
        }
    }
    
    func numberOfItems() -> Int {
        if let movies = filteredMovies {
            return movies.count
        }
        return 0
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return numberOfItems()
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return numberOfItems()
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = movieGridView.dequeueReusableCellWithReuseIdentifier("GridMovieCell", forIndexPath: indexPath) as! GridMovieViewCell
        
        let movie = filteredMovies![indexPath.row]
        let posterUrl = NSURL(string: movie.valueForKeyPath("posters.thumbnail") as! String)!
        
        cell.titleLabel.text = movie["title"] as? String
//        let posterRequest = NSURLRequest(URL: posterUrl)
        cell.posterView.setImageWithURL(posterUrl)
        
        
//        cell.posterView.setImageWithURLRequest(posterRequest, placeholderImage: nil, success: { (request, response, image) -> Void in
//            cell.posterView.alpha = 0.0
//            UIView.animateWithDuration(0.5, delay: 0.5, options: UIViewAnimationOptions.CurveEaseOut, animations: {
//                cell.posterView.image = image
//                cell.posterView.alpha = 1.0
//                }, completion: nil)
//            }, failure: nil)
        
        return cell

    }
    
    func  tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("MovieCell", forIndexPath: indexPath) as! MovieCell
        
        let movie = filteredMovies![indexPath.row]
        let posterUrl = NSURL(string: movie.valueForKeyPath("posters.thumbnail") as! String)!
        
        cell.titleLabel.text = movie["title"] as? String
        cell.synopsisLabel.text = movie["synopsis"] as? String
        let posterRequest = NSURLRequest(URL: posterUrl)
        
//        let posterRequest = NSURLRequest(URL: posterUrl, cachePolicy:  NSURLRequestReturnCacheDataElseLoad, timeoutInterval: 60)
//        NSURLCache.cachedResponseForRequest(posterRequest)
        
        cell.posterView.setImageWithURLRequest(posterRequest, placeholderImage: nil, success: { (request, response, image) -> Void in
                cell.posterView.alpha = 0.0
                UIView.animateWithDuration(0.5, delay: 0.5, options: UIViewAnimationOptions.CurveEaseOut, animations: {
                    cell.posterView.image = image
                    cell.posterView.alpha = 1.0
                }, completion: nil)
            }, failure: nil)
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let cell = sender as! MovieCell
        let indexPath = tableView.indexPathForCell(cell)
        let movie = movies![indexPath!.row]
        
        let movieDetailsViewController = segue.destinationViewController as! MoviesDetailsViewController
        movieDetailsViewController.movie = movie
        movieDetailsViewController.thumbnail = cell.posterView.image
    }
    
    func delay(delay:Double, closure:()->()) {
        dispatch_after(
            dispatch_time(
                DISPATCH_TIME_NOW,
                Int64(delay * Double(NSEC_PER_SEC))
            ),
            dispatch_get_main_queue(), closure)
    }
    
    func onRefresh() -> Void {
        delay(2, closure: {
            self.fetchMovies()
            self.refreshControl.endRefreshing()
        })
    }
    
    func getCategoryUrl() -> NSURL {
        var url = NSURL(string: "https://gist.githubusercontent.com/moog16/954f5c0148bd72334cbd/raw/fe94c7062c79893ef109b4952d0bd2ba673165ca/boxOfficeMovies.json")!
        let currentTabItem = categoryTabBar.selectedItem
        if currentTabItem == dvdTabBarItem {
            url = NSURL(string: "https://gist.githubusercontent.com/moog16/2a859bb9eda81134f376/raw/4e0986b75059935d845b0a5520e7ec3c4299fa01/topDvdMovies.json")!
        }

        return url
    }
    
    func fetchMovies() -> Void {
        let url = getCategoryUrl()
        let request = NSURLRequest(URL: url)
        MBProgressHUD.showHUDAddedTo(self.view, animated: true)
        let sessionConfiguration = NSURLSessionConfiguration.defaultSessionConfiguration()
        let session = NSURLSession(configuration: sessionConfiguration, delegate: nil, delegateQueue: NSOperationQueue.mainQueue())
        let tableWidth = self.tableView.frame.width
        let tableHeight = self.tableView.frame.height
        
        let jsonTask = session.dataTaskWithRequest(request) {(data, response, error) -> Void in
            do {
                let json = try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.MutableContainers)
                self.movies = json["movies"] as? [NSDictionary]
                self.filteredMovies = self.movies!
                if(!self.errorAlertView.hidden) {
                    self.errorAlertView.hidden = true
                    self.tableView.frame = CGRect(x: 0, y: self.originTableViewOriginY, width: tableWidth, height: tableHeight)
                }
            } catch {
                self.movies = nil
                self.filteredMovies = nil
                self.tableView.frame = CGRect(x: 0, y: self.originTableViewOriginY + 15, width: tableWidth, height: tableHeight)
                self.errorAlertView.hidden = false
            }
            self.tableView.reloadData()
            MBProgressHUD.hideHUDForView(self.view, animated: true)
        }
        
        jsonTask.resume()
    }

}