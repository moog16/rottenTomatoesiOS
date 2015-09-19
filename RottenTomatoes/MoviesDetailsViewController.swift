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
    
    var thumbnail: UIImage?
    
    var movie: NSDictionary!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        var url = movie.valueForKeyPath("posters.detailed") as! String
        let range = url.rangeOfString(".*cloudfront.net/", options: .RegularExpressionSearch)
        if let range = range {
            url = url.stringByReplacingCharactersInRange(range, withString: "https://content6.flixster.com/")
        }
        let posterUrl = NSURL(string: url)!
        
        posterView.setImageWithURL(posterUrl, placeholderImage: thumbnail)
        titleLabel.text = movie["title"] as? String
        synopsisLabel.text = movie["synopsis"] as? String
        

               
    }

}
