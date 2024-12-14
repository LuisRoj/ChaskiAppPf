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
        NotificationCenter.default.addObserver(self, selector: #selector(didPublishTweet), name: Notification.Name("tweetPublished"), object: nil)
        // Do any additional setup after loading the view.
    }
    @objc func didPublishTweet() {
        fetchTweets()  // Recargar los tuits
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: Notification.Name("tweetPublished"), object: nil)
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
                    content: data["content"] as! String,
                    username: data["username"] as? String,
                    imageURL: data["imageURL"] as? String,
                    userDisplayName: data["userDisplayName"] as? String,
                    profileImageURL: data["profileImageURL"] as? String,
                    timestamp: data["timestamp"] as? Timestamp
                )
            } ?? []
            print("Nuevos tweets obtenidos: \(self.tweets)")
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
        cell.configureCell(with: tweet)
        return cell
    }
    
    
    func loadImage(from storagePath: String, completion: @escaping (UIImage?) -> Void) {
        // Validate the URL first
        guard let url = URL(string: storagePath) else {
            print("Invalid image URL")
            completion(nil)
            return
        }
        
        // Use URLSession instead of Firebase Storage for generic URLs
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            // Check for errors
            if let error = error {
                print("Error downloading image: \(error.localizedDescription)")
                completion(nil)
                return
            }
            
            // Check for valid data
            guard let data = data, let image = UIImage(data: data) else {
                print("Could not create image from data")
                completion(nil)
                return
            }
            
            // Return image on main thread
            DispatchQueue.main.async {
                completion(image)
            }
        }.resume()
    }
    

}
