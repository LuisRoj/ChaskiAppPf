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
        profileImageURL.layer.cornerRadius = profileImageURL.frame.height / 2
        profileImageURL.clipsToBounds = true
        
        // Deshabilitar la edición de los TextFields
        nameTextField.isUserInteractionEnabled = false
        emailTextField.isUserInteractionEnabled = false
        
        // Llamar a fetchUserTweets después de obtener los datos del usuario
        fetchUserTweets()
        fetchUserData()
        

        // Configurar la tabla de tuits
        userTweetTableView.delegate = self
        userTweetTableView.dataSource = self
        let swipeGesture = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipeGesture))
        swipeGesture.direction = .left
        userTweetTableView.addGestureRecognizer(swipeGesture)
    }
    
    func fetchUserTweets() {
            guard let currentUser = Auth.auth().currentUser else {
                print("No hay un usuario autenticado.")
                return
            }
            
            let db = Firestore.firestore()
            
        // Obtener los tuits del usuario autenticado
        db.collection("tweets")
            .whereField("username", isEqualTo: currentUser.uid) // Usamos el UID del usuario autenticado
            .getDocuments { snapshot, error in
                if let error = error {
                    print("Error al recuperar los tuits del usuario: \(error.localizedDescription)")
                    return
                }

                guard let documents = snapshot?.documents else {
                    print("No se encontraron tuits para este usuario.")
                    return
                }

                // Verificar la cantidad de tuits recuperados
                print("Número de tuits: \(documents.count)")

                // Mapear los documentos a objetos Tweet
                self.userTweets = documents.compactMap { doc -> Tweet? in
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

                // Verificar el contenido de los tuits mapeados
                print("Tuits recuperados: \(self.userTweets.count)")
                print("Arreglo de tuits: \(self.userTweets)")

                // Recargar la tabla de tuits
                DispatchQueue.main.async {
                    self.userTweetTableView.reloadData()
                }
            }
        }
    
    func fetchUserData() {
        guard let currentUser = Auth.auth().currentUser else {
            print("No hay un usuario autenticado.")
            return
        }
        
        let db = Firestore.firestore()
        
        // Obtener el documento del usuario autenticado
        db.collection("users").whereField("email", isEqualTo: currentUser.email ?? "").getDocuments { querySnapshot, error in
            if let error = error {
                print("Error al obtener datos del usuario: \(error.localizedDescription)")
                return
            }
            
            guard let documents = querySnapshot?.documents, let userDoc = documents.first else {
                print("No se encontraron datos para el usuario.")
                return
            }
            
            let userData = userDoc.data()
            let userName = userData["name"] as? String ?? "Nombre no disponible"
            let userEmail = userData["email"] as? String ?? "Correo no disponible"
            let userProfileImageURL = userData["profileImageURL"] as? String
            
            // Actualizar los campos del perfil
            DispatchQueue.main.async {
                self.nameTextField.text = userName
                self.emailTextField.text = userEmail
                
                if let profileImageURL = userProfileImageURL, let url = URL(string: profileImageURL) {
                    self.profileImageURL.af.setImage(
                        withURL: url,
                        placeholderImage: UIImage(named: "placeholder"),
                        imageTransition: .crossDissolve(0.2)
                    )
                } else {
                    self.profileImageURL.image = UIImage(named: "placeholder")
                }
            }
        }
    }
    
    @IBAction func logoutButtonTapped(_ sender: UIButton) {
        let alert = UIAlertController(title: "Cerrar Sesión", message: "¿Estás seguro de que deseas cerrar sesión?", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Cancelar", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Cerrar Sesión", style: .destructive, handler: { _ in
            self.performLogout()
        }))
        
        self.present(alert, animated: true, completion: nil)
    }
    
    private func performLogout() {
        // 2. Borrar los datos de sesión (ejemplo: token en UserDefaults)
        UserDefaults.standard.removeObject(forKey: "authToken")
        UserDefaults.standard.synchronize()
        
        // 3. Redirigir al LoginViewController
        redirectToLogin()
    }
    
    private func redirectToLogin() {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let sceneDelegate = windowScene.delegate as? SceneDelegate,
              let loginViewController = storyboard?.instantiateViewController(withIdentifier: "loginViewController") else {
            return
        }
        
        // Establecer loginViewController como el rootViewController
        sceneDelegate.window?.rootViewController = loginViewController
        sceneDelegate.window?.makeKeyAndVisible()
    }
    
    
        
        @objc func handleSwipeGesture(gesture: UISwipeGestureRecognizer) {
            let point = gesture.location(in: userTweetTableView)
            if let indexPath = userTweetTableView.indexPathForRow(at: point) {
                let tweetToDelete = userTweets[indexPath.row]
                deleteTweet(tweetToDelete)
            }
        }
        
        func deleteTweet(_ tweet: Tweet) {
            let db = Firestore.firestore()
            
            // Eliminar el tuit de Firebase
            db.collection("tweets").document(tweet.id).delete { error in
                if let error = error {
                    print("Error al eliminar el tuit: \(error.localizedDescription)")
                } else {
                    // Actualizar la tabla de tuits eliminados
                    if let index = self.userTweets.firstIndex(where: { $0.id == tweet.id }) {
                        self.userTweets.remove(at: index)
                        self.userTweetTableView.reloadData()
                    }
                }
            }
        }
        
    // MARK: - UITableViewDataSource
        func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            print("Número de tuits: \(userTweets.count)") // Log para verificar el número de tuits
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
        
        // MARK: - UITableViewDelegate
        func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
            return UITableView.automaticDimension
        }
        
        func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
            return 150
        }
}
