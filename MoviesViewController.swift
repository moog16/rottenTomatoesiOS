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
    var refreshControlTableView: UIRefreshControl!
    var refreshControlGridView: UIRefreshControl!
    var originTableViewOriginY: CGFloat!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let URLCache = NSURLCache(memoryCapacity: 4 * 1024 * 1024, diskCapacity: 20 * 1024 * 1024, diskPath: nil)
        NSURLCache.setSharedURLCache(URLCache)
        gridOrListViewSegmentedControl.selectedSegmentIndex = 0
        
        tableView.dataSource = self
        tableView.delegate = self
        movieGridView.delegate = self
        movieGridView.dataSource = self
        categoryTabBar.delegate = self
        movieSearchBar.delegate = self
        
        originTableViewOriginY = tableView.frame.origin.y
        categoryTabBar.selectedItem = boxOfficeTabBarItem
        
        fetchMovies()
        
        refreshControlTableView = UIRefreshControl()
        refreshControlTableView.addTarget(self, action: "onRefresh", forControlEvents: UIControlEvents.ValueChanged)
        self.tableView.insertSubview(refreshControlTableView, atIndex: 0)
        
        refreshControlGridView = UIRefreshControl()
        refreshControlGridView.addTarget(self, action: "onRefresh", forControlEvents: UIControlEvents.ValueChanged)
        self.movieGridView.insertSubview(refreshControlGridView, atIndex: 0)
        
    }
    
    @IBAction func onChangeGridOrList(sender: AnyObject) {
        if gridOrListViewSegmentedControl.selectedSegmentIndex == 1 {
            movieGridView.hidden = false
            movieGridView.reloadData()
        } else {
            movieGridView.hidden = true
            tableView.reloadData()
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
            if gridOrListViewSegmentedControl.selectedSegmentIndex == 1 {
                movieGridView.reloadData()
            } else {
                tableView.reloadData()
            }

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
        let posterRequest = NSURLRequest(URL: posterUrl)
        
        cell.posterView.setImageWithURLRequest(posterRequest, placeholderImage: nil, success: { (request, response, image) -> Void in
            //if status code is 0, then it is loaded from the cache
            if response.statusCode == 0 {
                cell.posterView.image = image
            } else {
                cell.posterView.alpha = 0.0
                UIView.animateWithDuration(0.5, delay: 0.5, options: UIViewAnimationOptions.CurveEaseOut, animations: {
                    cell.posterView.image = image
                    cell.posterView.alpha = 1.0
                    }, completion: nil)
            }

            
            }, failure: nil)
        
        return cell

    }
    
    func  tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("MovieCell", forIndexPath: indexPath) as! MovieCell
        
        let movie = filteredMovies![indexPath.row]
        let posterUrl = NSURL(string: movie.valueForKeyPath("posters.thumbnail") as! String)!
        
        cell.titleLabel.text = movie["title"] as? String
        cell.synopsisLabel.text = movie["synopsis"] as? String
        let posterRequest = NSURLRequest(URL: posterUrl)
        
        cell.posterView.setImageWithURLRequest(posterRequest, placeholderImage: nil, success: { (request, response, image) -> Void in
                if response.statusCode == 0 {
                    cell.posterView.image = image
                } else {
                    cell.posterView.alpha = 0.0
                    UIView.animateWithDuration(0.5, delay: 0.5, options: UIViewAnimationOptions.CurveEaseOut, animations: {
                        cell.posterView.image = image
                        cell.posterView.alpha = 1.0
                    }, completion: nil)
                }
            }, failure: nil)
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    func setDetailsView(image: UIImage, indexPath: NSIndexPath, segue: UIStoryboardSegue) -> Void {
        let movie = movies![indexPath.row]
        
        let movieDetailsViewController = segue.destinationViewController as! MoviesDetailsViewController
        movieDetailsViewController.movie = movie
        movieDetailsViewController.thumbnail = image
    }
    

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if gridOrListViewSegmentedControl.selectedSegmentIndex == 1 {
            let cell = sender as! GridMovieViewCell
            let image = cell.posterView.image
            let indexPath = movieGridView.indexPathForCell(cell)
            setDetailsView(image!, indexPath: indexPath!, segue: segue)
        } else {
            let cell = sender as! MovieCell
            let image = cell.posterView.image
            let indexPath = tableView.indexPathForCell(cell)
            setDetailsView(image!, indexPath: indexPath!, segue: segue)
        }
    }
    
    func onRefresh() -> Void {
        self.fetchMovies()
        if gridOrListViewSegmentedControl.selectedSegmentIndex == 0 {
            self.refreshControlTableView.endRefreshing()
        } else {
            self.refreshControlGridView.endRefreshing()
        }
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