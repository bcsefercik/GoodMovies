//
//  MovieSearchViewCell.swift
//  GoodMovies
//
//  Created by Bugra Sefercik on 17/08/2016.
//  Copyright © 2016 Bugra Sefercik. All rights reserved.
//

import UIKit

class MovieSearchViewCell: UITableViewCell {

    @IBOutlet weak var movieTitle: UILabel!
    @IBOutlet weak var movieYear: UILabel!
    @IBOutlet weak var moviePosterView: UIImageView!
    
    var moviePresentation: MoviePresentation?{
        didSet{
            updateUI()
        }
    }

    private func updateUI(){
        movieTitle?.text = moviePresentation?.title
        movieYear?.text = moviePresentation?.year
        
        if let posterURL = moviePresentation?.poster{
            if let imageData = NSData(contentsOfURL: posterURL){
                moviePosterView?.image = UIImage(data: imageData)
            }
        }
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
