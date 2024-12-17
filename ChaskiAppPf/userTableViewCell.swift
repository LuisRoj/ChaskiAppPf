//
//  userTableViewCell.swift
//  ChaskiAppPf
//
//  Created by DAMII on 16/12/24.
//

import UIKit

class userTableViewCell: UITableViewCell {
    
    
    @IBOutlet weak var profileImageView: UIImageView!
    
    @IBOutlet weak var tweetImageView: UIImageView!
    
    @IBOutlet weak var userDisplayNameLabel: UILabel!
    
    @IBOutlet weak var contentLabel: UILabel!
    
    
    

    override func awakeFromNib() {
            super.awakeFromNib()
            // Configuración de la imagen de perfil redonda
            profileImageView.layer.cornerRadius = profileImageView.frame.height / 2
            profileImageView.clipsToBounds = true
        }

        override func setSelected(_ selected: Bool, animated: Bool) {
            super.setSelected(selected, animated: animated)
        }

        func configureCell(with tweet: Tweet) {
            // Nombre del usuario
            userDisplayNameLabel.text = tweet.userDisplayName ?? "Unknown"
            
            // Contenido del tuit
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
            tweetImageView.isHidden = tweet.imageURL == nil
            if let imageURL = tweet.imageURL, let url = URL(string: imageURL) {
                tweetImageView.af.setImage(withURL: url)
            }
        }
    }
