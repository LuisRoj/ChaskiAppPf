//
//  PublishViewController.swift
//  ChaskiAppPf
//
//  Created by DAMII on 14/12/24.
//

import UIKit
import FirebaseAuth
import FirebaseStorage
import FirebaseFirestore

class PublishViewController: UIViewController , UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    
    @IBOutlet weak var tweetTextField: UITextField!
    @IBOutlet weak var publishTweetImageView: UIImageView!
    
    var selectedImage: UIImage?
    
    override func viewDidLoad() {
            super.viewDidLoad()
        }
        
        @IBAction func publishTweetTapped(_ sender: UIButton) {
            guard let content = tweetTextField.text, !content.isEmpty,
                  let currentUser = Auth.auth().currentUser else { return }
            
            let db = Firestore.firestore()
            
            // Buscar el documento del usuario por UID en lugar de usar currentUser.uid directamente
            db.collection("users").whereField("email", isEqualTo: currentUser.email ?? "").getDocuments { querySnapshot, error in
                if let error = error {
                    print("Error al obtener datos del usuario: \(error.localizedDescription)")
                    return
                }
                
                guard let documents = querySnapshot?.documents, let userDoc = documents.first else {
                    print("No se encontraron datos para el usuario.")
                    return
                }
                
                // Extraer datos del usuario
                let userData = userDoc.data()
                let userDisplayName = userData["name"] as? String ?? "Default Name"
                let profileImageURL = userData["profileImageURL"] as? String
                
                // Crear datos del tuit
                var tweetData: [String: Any] = [
                    "content": content,
                    "username": userDoc.documentID, // Usar el ID personalizado como username
                    "userDisplayName": userDisplayName,
                    "profileImageURL": profileImageURL ?? "",
                    "timestamp": Timestamp(date: Date())
                ]
                
                // Subir la imagen si existe
                if let imageData = self.selectedImage?.jpegData(compressionQuality: 0.8) {
                    let storageRef = Storage.storage().reference().child("tweetImages/\(UUID().uuidString).jpg")
                    storageRef.putData(imageData, metadata: nil) { _, error in
                        if let error = error {
                            print("Error al subir la imagen: \(error.localizedDescription)")
                            return
                        }
                        
                        storageRef.downloadURL { url, error in
                            if let error = error {
                                print("Error al obtener la URL de la imagen: \(error.localizedDescription)")
                                return
                            }
                            
                            guard let imageURL = url else {
                                print("No se pudo obtener la URL de la imagen.")
                                return
                            }
                            
                            tweetData["imageURL"] = imageURL.absoluteString
                            
                            db.collection("tweets").addDocument(data: tweetData) { error in
                                if let error = error {
                                    print("Error al guardar el tweet: \(error.localizedDescription)")
                                } else {
                                    print("Tweet publicado con éxito.")
                                    self.dismiss(animated: true)
                                }
                            }
                        }
                    }
                } else {
                    db.collection("tweets").addDocument(data: tweetData) { error in
                        if let error = error {
                            print("Error al guardar el tweet: \(error.localizedDescription)")
                        } else {
                            print("Tweet publicado con éxito.")
                            NotificationCenter.default.post(name: Notification.Name("tweetPublished"), object: nil)
                            self.dismiss(animated: true)
                        }
                    }
                }
            }
        }
        
        @IBAction func uploadPhotoTweetPublish(_ sender: UIButton) {
            let imagePickerController = UIImagePickerController()
            imagePickerController.delegate = self
            imagePickerController.sourceType = .photoLibrary
            present(imagePickerController, animated: true, completion: nil)
        }

        // MARK: - UIImagePickerControllerDelegate
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let selectedImage = info[.originalImage] as? UIImage {
                self.selectedImage = selectedImage
                publishTweetImageView.image = selectedImage
            }
            dismiss(animated: true, completion: nil)
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            dismiss(animated: true, completion: nil)
        }
    }
