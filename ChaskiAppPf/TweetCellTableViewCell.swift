//
//  TweetCellTableViewCell.swift
//  ChaskiAppPf
//
//  Created by Luis on 12/12/24.
//

import UIKit
import AlamofireImage

class TweetCellTableViewCell: UITableViewCell {
    
    @IBOutlet weak var usernameLabel: UILabel!    
    @IBOutlet weak var userDisplayNameLabel: UILabel!
    @IBOutlet weak var contentLabel: UILabel!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var tweetImageView: UIImageView!
    
    
    override func awakeFromNib() {
            super.awakeFromNib()
            profileImageView.layer.cornerRadius = profileImageView.frame.height / 2
            profileImageView.clipsToBounds = true
        }

    override func prepareForReuse() {
            super.prepareForReuse()
            profileImageView.image = nil
            tweetImageView.image = nil
            tweetImageView.isHidden = false
        }
        
        func configureCell(with tweet: Tweet) {
            userDisplayNameLabel.text = tweet.userDisplayName ?? "Unknown"
            usernameLabel.text = tweet.username ?? "Unknown"
            contentLabel.text = tweet.content
            
            // Imagen de perfil
            if let profileImageURL = tweet.profileImageURL, let url = URL(string: profileImageURL) {
                profileImageView.af.setImage(
                    withURL: url,
                    placeholderImage: UIImage(named: "placeholder"),
                    imageTransition: .crossDissolve(0.2)
                )
            } else {
                profileImageView.image = UIImage(named: "placeholder")
            }
            
            // Imagen del tuit
            if let tweetImageURL = tweet.imageURL, let url = URL(string: tweetImageURL) {
                tweetImageView.af.setImage(
                    withURL: url,
                    placeholderImage: UIImage(named: "placeholder"),
                    imageTransition: .crossDissolve(0.2)
                )
            } else {
                tweetImageView.isHidden = true
            }
        }
    }

