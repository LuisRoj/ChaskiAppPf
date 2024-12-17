//
//  profileViewController.swift
//  ChaskiAppPf
//
//  Created by Luis on 12/12/24.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore
import AlamofireImage

class profileViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var profileImageURL: UIImageView!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    
    @IBOutlet weak var userTweetTableView: UITableView!
    
    var userTweets: [Tweet] = []
    
    override func viewDidLoad() {
            super.viewDidLoad()
            
            // Configuración inicial
            setupUI()
            configureTableView()
            
            // Cargar datos
            fetchUserDataAndTweets()
        }
        
        private func setupUI() {
            // Redondear la imagen de perfil
            profileImageURL.layer.cornerRadius = profileImageURL.frame.height / 2
            profileImageURL.clipsToBounds = true
            
            // Deshabilitar la edición de los campos
            nameTextField.isUserInteractionEnabled = false
            emailTextField.isUserInteractionEnabled = false
        }
        
        private func configureTableView() {
            userTweetTableView.delegate = self
            userTweetTableView.dataSource = self
            userTweetTableView.estimatedRowHeight = 150
            userTweetTableView.rowHeight = UITableView.automaticDimension
            
            // Gesture para eliminar tuits deslizando
            let swipeGesture = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipeGesture))
            swipeGesture.direction = .left
            userTweetTableView.addGestureRecognizer(swipeGesture)
        }
        
        // MARK: - Carga de Datos
        private func fetchUserDataAndTweets() {
            let dispatchGroup = DispatchGroup()
            
            // Obtener datos del usuario
            dispatchGroup.enter()
            fetchUserData {
                dispatchGroup.leave()
            }
            
            // Obtener tuits del usuario
            dispatchGroup.enter()
            fetchUserTweets {
                dispatchGroup.leave()
            }
            
            // Recargar tabla después de que todos los datos hayan sido cargados
            dispatchGroup.notify(queue: .main) {
                print("Datos del usuario y tuits cargados completamente.")
                self.userTweetTableView.reloadData()
            }
        }
        
        private func fetchUserData(completion: @escaping () -> Void) {
            guard let currentUser = Auth.auth().currentUser else {
                print("No hay un usuario autenticado.")
                completion()
                return
            }
            
            let db = Firestore.firestore()
            db.collection("users").whereField("email", isEqualTo: currentUser.email ?? "").getDocuments { querySnapshot, error in
                if let error = error {
                    print("Error al obtener datos del usuario: \(error.localizedDescription)")
                    completion()
                    return
                }
                
                guard let documents = querySnapshot?.documents, let userDoc = documents.first else {
                    print("No se encontraron datos para el usuario.")
                    completion()
                    return
                }
                
                let userData = userDoc.data()
                DispatchQueue.main.async {
                    self.nameTextField.text = userData["name"] as? String ?? "Nombre no disponible"
                    self.emailTextField.text = userData["email"] as? String ?? "Correo no disponible"
                    
                    if let profileImageURL = userData["profileImageURL"] as? String, let url = URL(string: profileImageURL) {
                        self.profileImageURL.af.setImage(
                            withURL: url,
                            placeholderImage: UIImage(named: "placeholder"),
                            imageTransition: .crossDissolve(0.2)
                        )
                    } else {
                        self.profileImageURL.image = UIImage(named: "placeholder")
                    }
                }
                completion()
            }
        }
        
        private func fetchUserTweets(completion: @escaping () -> Void) {
            guard let currentUser = Auth.auth().currentUser else {
                print("No hay un usuario autenticado.")
                completion()
                return
            }
            
            let db = Firestore.firestore()
            db.collection("tweets").whereField("username", isEqualTo: currentUser.uid).getDocuments { snapshot, error in
                if let error = error {
                    print("Error al recuperar los tuits del usuario: \(error.localizedDescription)")
                    completion()
                    return
                }
                
                guard let documents = snapshot?.documents else {
                    print("No se encontraron tuits para este usuario.")
                    completion()
                    return
                }
                
                self.userTweets = documents.compactMap { doc in
                    let data = doc.data()
                    return Tweet(
                        id: doc.documentID,
                        content: data["content"] as? String ?? "Sin contenido",
                        username: data["username"] as? String,
                        imageURL: data["imageURL"] as? String,
                        userDisplayName: data["userDisplayName"] as? String,
                        profileImageURL: data["profileImageURL"] as? String,
                        timestamp: data["timestamp"] as? Timestamp
                    )
                }
                
                DispatchQueue.main.async {
                    self.userTweetTableView.reloadData()
                }
                completion()
            }
        }
        
        // MARK: - Logout
        @IBAction func logoutButtonTapped(_ sender: UIButton) {
            let alert = UIAlertController(title: "Cerrar Sesión", message: "¿Estás seguro de que deseas cerrar sesión?", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Cancelar", style: .cancel, handler: nil))
            alert.addAction(UIAlertAction(title: "Cerrar Sesión", style: .destructive, handler: { _ in
                self.performLogout()
            }))
            self.present(alert, animated: true, completion: nil)
        }
        
        private func performLogout() {
            do {
                try Auth.auth().signOut()
                redirectToLogin()
            } catch let error {
                print("Error al cerrar sesión: \(error.localizedDescription)")
            }
        }
        
        private func redirectToLogin() {
            guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                  let sceneDelegate = windowScene.delegate as? SceneDelegate,
                  let loginViewController = storyboard?.instantiateViewController(withIdentifier: "loginViewController") else {
                return
            }
            
            sceneDelegate.window?.rootViewController = loginViewController
            sceneDelegate.window?.makeKeyAndVisible()
        }
        
        // MARK: - Gestos
        @objc func handleSwipeGesture(gesture: UISwipeGestureRecognizer) {
            let point = gesture.location(in: userTweetTableView)
            if let indexPath = userTweetTableView.indexPathForRow(at: point) {
                let tweetToDelete = userTweets[indexPath.row]
                confirmDelete(tweetToDelete, at: indexPath)
            }
        }
        
        private func confirmDelete(_ tweet: Tweet, at indexPath: IndexPath) {
            let alert = UIAlertController(title: "Eliminar Tuit", message: "¿Estás seguro de que deseas eliminar este tuit?", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Cancelar", style: .cancel, handler: nil))
            alert.addAction(UIAlertAction(title: "Eliminar", style: .destructive, handler: { _ in
                self.deleteTweet(tweet, at: indexPath)
            }))
            self.present(alert, animated: true, completion: nil)
        }
        
        private func deleteTweet(_ tweet: Tweet, at indexPath: IndexPath) {
            let db = Firestore.firestore()
            db.collection("tweets").document(tweet.id).delete { error in
                if let error = error {
                    print("Error al eliminar el tuit: \(error.localizedDescription)")
                    return
                }
                
                self.userTweets.remove(at: indexPath.row)
                self.userTweetTableView.deleteRows(at: [indexPath], with: .automatic)
            }
        }
        
        // MARK: - UITableViewDataSource
        func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            return userTweets.count
        }
        
        func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "userTableViewCell", for: indexPath) as? userTableViewCell else {
                return UITableViewCell()
            }
            
            let tweet = userTweets[indexPath.row]
            cell.configureCell(with: tweet)
            return cell
        }
    }
