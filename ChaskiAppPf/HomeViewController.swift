//
//  HomeViewController.swift
//  ChaskiAppPf
//
//  Created by Luis on 12/12/24.
//

import UIKit
import FirebaseFirestore
import FirebaseStorage

class HomeViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    
    @IBOutlet weak var homeTableView: UITableView!
    var tweets: [Tweet] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        homeTableView.delegate = self
        homeTableView.dataSource = self
        fetchTweets()
        // Do any additional setup after loading the view.
    }
    
    // MARK: - Firebase: Obtener los tuits
        func fetchTweets() {
            let db = Firestore.firestore()
            db.collection("tweets").order(by: "timestamp", descending: true).getDocuments { (snapshot, error) in
                if let error = error {
                    print("Error al obtener tuits: \(error.localizedDescription)")
                    return
                }
                self.tweets = snapshot?.documents.compactMap { doc -> Tweet? in
                    let data = doc.data()
                    return Tweet(
                        id: doc.documentID,
                        content: data["content"] as? String,
                        username: data["username"] as? String,
                        imageURL: data["imageURL"] as? String,
                        userDisplayName: data["userDisplayName"] as? String,
                        timestamp: data["timestamp"] as? Timestamp
                    )
                } ?? []
                self.homeTableView.reloadData()
            }
        }
        
        // MARK: - Table View Data Source
        func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            return tweets.count
        }
        
        func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            let cell = tableView.dequeueReusableCell(withIdentifier: "TweetCell", for: indexPath) as! TweetCellTableViewCell
            let tweet = tweets[indexPath.row]
            cell.usernameLabel.text = tweet.username
            cell.userDisplayNameLabel.text = tweet.userDisplayName
            cell.contentLabel.text = tweet.content
            if let imageURL = tweet.imageURL {
                // Carga la imagen desde la URL (usa una librería o extensión para manejo de imágenes) Como se hace esto??
            }
            return cell
        }
    
    
    @IBAction func publishButtonTapped(_ sender: UIButton) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
                if let publishVC = storyboard.instantiateViewController(withIdentifier: "PublishViewController") as? PublishViewController {
                    publishVC.modalPresentationStyle = .fullScreen
                    self.present(publishVC, animated: true, completion: nil)
                }
    }
    

}
