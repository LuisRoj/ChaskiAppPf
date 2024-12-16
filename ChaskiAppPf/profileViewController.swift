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

class profileViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var profileImageURL: UIImageView!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        profileImageURL.layer.cornerRadius = profileImageURL.frame.height / 2
        profileImageURL.clipsToBounds = true
            
        // Deshabilitar la edición de los TextFields
        nameTextField.isUserInteractionEnabled = false
        emailTextField.isUserInteractionEnabled = false
                
        fetchUserData()
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
}
