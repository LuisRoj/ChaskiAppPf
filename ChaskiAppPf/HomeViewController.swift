//
//  HomeViewController.swift
//  ChaskiAppPf
//
//  Created by Luis on 12/12/24.
//

import UIKit
import FirebaseFirestore
import FirebaseStorage
import Alamofire
import AlamofireImage

class HomeViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    
    @IBOutlet weak var homeTableView: UITableView!
    var tweets: [Tweet] = []
        
        override func viewDidLoad() {
            super.viewDidLoad()
            
            homeTableView.delegate = self
            homeTableView.dataSource = self
            
            // Configurar Pull to Refresh
            let refreshControl = UIRefreshControl()
            refreshControl.addTarget(self, action: #selector(refreshTweets), for: .valueChanged)
            homeTableView.refreshControl = refreshControl
            
            // Inicializar datos
            fetchTweets()
            
            // Notificación para recargar tuits tras publicar
            NotificationCenter.default.addObserver(self, selector: #selector(didPublishTweet), name: Notification.Name("tweetPublished"), object: nil)
        }
        
        @objc func refreshTweets() {
            fetchTweets()
            homeTableView.refreshControl?.endRefreshing()
        }
        
        @objc func didPublishTweet() {
            DispatchQueue.main.async {
                self.fetchTweets()
            }
        }
        
        deinit {
            NotificationCenter.default.removeObserver(self, name: Notification.Name("tweetPublished"), object: nil)
        }
        
        // MARK: - Firebase: Obtener los tuits
        func fetchTweets() {
            let db = Firestore.firestore()
            db.collection("tweets").order(by: "timestamp", descending: true).getDocuments { snapshot, error in
                guard let documents = snapshot?.documents, error == nil else { return }
                
                self.tweets = documents.compactMap { doc -> Tweet? in
                    let data = doc.data()
                    return Tweet(
                        id: doc.documentID,
                        content: data["content"] as! String,
                        username: data["username"] as? String,
                        imageURL: data["imageURL"] as? String,
                        userDisplayName: data["userDisplayName"] as? String,
                        profileImageURL: data["profileImageURL"] as? String,
                        timestamp: data["timestamp"] as? Timestamp
                    )
                }
                
                DispatchQueue.main.async {
                    self.homeTableView.reloadData()
                }
            }
        }
        
        // MARK: - UITableViewDataSource
        func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            return tweets.count
        }
        
        func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "TweetCell", for: indexPath) as? TweetCellTableViewCell else {
                return UITableViewCell()
            }
            
            let tweet = tweets[indexPath.row]
            cell.configureCell(with: tweet)
            
            return cell
        }
        
        // MARK: - UITableViewDelegate
        func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
            return UITableView.automaticDimension
        }
        
        func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
            return 150
        }
    }
