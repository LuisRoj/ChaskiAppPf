    //
    //  TweetCellTableViewCell.swift
    //  ChaskiAppPf
    //
    //  Created by Luis on 12/12/24.
    //

    import UIKit
    import AlamofireImage

    class TweetCellTableViewCell: UITableViewCell {
           
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

