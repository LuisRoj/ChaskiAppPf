//
//  TweetCellTableViewCell.swift
//  ChaskiAppPf
//
//  Created by Luis on 12/12/24.
//

import UIKit

class TweetCellTableViewCell: UITableViewCell {
    
    @IBOutlet weak var usernameLabel: UILabel!
    
    
    @IBOutlet weak var userDisplayNameLabel: UILabel!
    
    @IBOutlet weak var contentLabel: UILabel!
    
    @IBOutlet weak var profileImageView: UIImageView!
    
    @IBOutlet weak var tweetImageView: UIImageView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
