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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        let url = NSURL(string: "https://gist.githubusercontent.com/timothy1ee/d1778ca5b944ed974db0/raw/489d812c7ceeec0ac15ab77bf7c47849f2d1eb2b/gistfile1.json")!
        
//        let url = NSURL(string: "https://gist.githubusercontent.com/timothy1ee0/d1778ca5b944ed974db0/raw/4c15ab77bf7c47849f2d1eb2b/gistfile1.json")! // bad URL
        fetchMovies(url)

//        refreshControl = UIRefreshControl()
//        refreshControl.addTarget(self, action: "onRefresh", forControlEvents: UIControlEvents.ValueChanged)
//        self.tableView.insertSubview(refreshControl, atIndex: 0)
        
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
    
    func fetchMovies(url: NSURL) -> Void {
        let request = NSURLRequest(URL: url)
        MBProgressHUD.showHUDAddedTo(self.view, animated: true)
        let sessionConfiguration = NSURLSessionConfiguration.defaultSessionConfiguration()
        let session = NSURLSession(configuration: sessionConfiguration, delegate: nil, delegateQueue: NSOperationQueue.mainQueue())
        let jsonTask = session.dataTaskWithRequest(request) {(data, response, error) -> Void in
            do {
                let json = try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.MutableContainers)
                self.movies = json["movies"] as? [NSDictionary]
                self.tableView.reloadData()
            } catch {
                self.errorAlertView.hidden = false
                print("error: \(error)")
            }
            MBProgressHUD.hideHUDForView(self.view, animated: true)
        }
        
        jsonTask.resume()
    }

}