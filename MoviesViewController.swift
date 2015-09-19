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

class MoviesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var errorAlertView: UIView!
    
    var movies: [NSDictionary]?
    var refreshControl: UIRefreshControl!
    var originTableViewOriginY: CGFloat!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        originTableViewOriginY = tableView.frame.origin.y
        
        let url = NSURL(string: "https://gist.githubusercontent.com/timothy1ee0/d1778ca5b944ed974db0/raw/4c15ab77bf7c47849f2d1eb2b/gistfile1.json")! // bad URL

        fetchMovies(url)

        refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: "onRefresh", forControlEvents: UIControlEvents.ValueChanged)
        self.tableView.insertSubview(refreshControl, atIndex: 0)
        
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let movies = movies {
            return movies.count
        }
        return 0
    }
    
    func  tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("MovieCell", forIndexPath: indexPath) as! MovieCell
        
        let movie = movies![indexPath.row]
        let posterUrl = NSURL(string: movie.valueForKeyPath("posters.thumbnail") as! String)!
        
        cell.titleLabel.text = movie["title"] as? String
        cell.synopsisLabel.text = movie["synopsis"] as? String
        print(posterUrl)
        cell.posterView.setImageWithURL(posterUrl)
        
        return cell
    }
    
    func tableView(tableView: UITableView, didDeselectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        print("deselecting")
    }
    

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let cell = sender as! MovieCell
        let indexPath = tableView.indexPathForCell(cell)
        let movie = movies![indexPath!.row]
        
        let movieDetailsViewController = segue.destinationViewController as! MoviesDetailsViewController
        movieDetailsViewController.movie = movie
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
        let url = NSURL(string: "https://gist.githubusercontent.com/timothy1ee/d1778ca5b944ed974db0/raw/489d812c7ceeec0ac15ab77bf7c47849f2d1eb2b/gistfile1.json")!
        delay(2, closure: {
            self.fetchMovies(url)
            self.refreshControl.endRefreshing()
        })

    }
    
    func fetchMovies(url: NSURL) -> Void {
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
                if(!self.errorAlertView.hidden) {
                    self.errorAlertView.hidden = true
                    self.tableView.frame = CGRect(x: 0, y: self.originTableViewOriginY, width: tableWidth, height: tableHeight)
                }
                self.tableView.reloadData()
            } catch {
                self.tableView.frame = CGRect(x: 0, y: self.originTableViewOriginY + 50, width: tableWidth, height: tableHeight)
                self.errorAlertView.hidden = false
                print("error: \(error)")
            }
            MBProgressHUD.hideHUDForView(self.view, animated: true)
        }
        
        jsonTask.resume()
    }

}