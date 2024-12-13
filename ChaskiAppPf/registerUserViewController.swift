//
//  registerUserViewController.swift
//  ChaskiAppPf
//
//  Created by Luis on 12/12/24.
//

import UIKit
import FirebaseAuth
import FirebaseStorage
import FirebaseFirestore

class registerUserViewController: UIViewController {
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var profileImageView: UIImageView!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        profileImageView.isUserInteractionEnabled = true
                let tapGesture = UITapGestureRecognizer(target: self, action: #selector(selectImage))
                profileImageView.addGestureRecognizer(tapGesture)
    }
    
    @objc func selectImage() {
            let picker = UIImagePickerController()
            picker.delegate = self
            picker.sourceType = .photoLibrary
            present(picker, animated: true)
        }
    
    
    @IBAction func uploadPhotoButtonTapped(_ sender: UIButton) {
        selectImage()
    }
    
        
        @IBAction func registerButtonTapped(_ sender: UIButton) {
            guard let email = emailTextField.text,
                  let password = passwordTextField.text,
                  let name = nameTextField.text,
                  let profileImage = profileImageView.image?.jpegData(compressionQuality: 0.8) else { return }

            Auth.auth().createUser(withEmail: email, password: password) { result, error in
                guard let userId = result?.user.uid, error == nil else {
                    print("Error al registrar: \(error?.localizedDescription ?? "Desconocido")")
                    return
                }

                let storageRef = Storage.storage().reference().child("profileImages/\(userId).jpg")
                storageRef.putData(profileImage, metadata: nil) { _, error in
                    guard error == nil else {
                        print("Error al subir imagen: \(error?.localizedDescription ?? "Desconocido")")
                        return
                    }

                    storageRef.downloadURL { url, _ in
                        guard let imageURL = url else { return }
                        let db = Firestore.firestore()
                        db.collection("users").document(userId).setData([
                            "name": name,
                            "email": email,
                            "profileImageURL": imageURL.absoluteString
                        ]) { error in
                            if error == nil {
                                print("Usuario registrado correctamente")
                                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                                if let loginVC = storyboard.instantiateViewController(withIdentifier: "loginViewController") as? loginViewController {
                                    loginVC.modalPresentationStyle = .fullScreen
                                    self.present(loginVC, animated: true, completion: nil)
                                }

                            }
                        }
                    }
                }
            }
        }
    }

    // La extensión debe estar fuera de la clase principal
    extension registerUserViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let image = info[.originalImage] as? UIImage {
                profileImageView.image = image
            }
            picker.dismiss(animated: true)
        }
    }
