//
//  MoviesViewController.swift
//  RottenTomatoes
//
//  Created by Matthew Goo on 9/15/15.
//  Copyright © 2015 mattgoo. All rights reserved.
//

import UIKit

class MoviesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var tableView: UITableView!
    
    var movies: [NSDictionary]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        
        if let filePath = NSBundle.mainBundle().pathForResource("./box_office", ofType: "json") {
            if let data = NSData(contentsOfFile: filePath) {
                do {
                    let json = try NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.MutableContainers)
                    movies = json["movies"] as! [NSDictionary]
                } catch {
                    
                }
            }
        }
        
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let movies = movies {
            return movies.count
        }
        return 0
    }
    
    func  tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCellWithIdentifier("MovieCell", forIndexPath: indexPath)
        
        let movie = movies![indexPath.row]
        cell.textLabel?.text = movie["title"] as? String
        
        return cell
    }

}