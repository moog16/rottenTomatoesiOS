//
//  MoviesDetailsViewController.swift
//  RottenTomatoes
//
//  Created by Matthew Goo on 9/17/15.
//  Copyright © 2015 mattgoo. All rights reserved.
//

import UIKit

class MoviesDetailsViewController: UIViewController {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var synopsisLabel: UILabel!
    @IBOutlet weak var posterView: UIImageView!
    
    var movie: NSDictionary!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        var url = movie.valueForKeyPath("posters.detailed") as! String
        let range = url.rangeOfString(".*cloudfront.net/", options: .RegularExpressionSearch)
        print("range: \(range)")
        if let range = range {
            url = url.stringByReplacingCharactersInRange(range, withString: "https://content6.flixster.com/")
        }
        let posterUrl = NSURL(string: url)!
        
        posterView.setImageWithURL(posterUrl)
        titleLabel.text = movie["title"] as? String
        synopsisLabel.text = movie["synopsis"] as? String

               
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
