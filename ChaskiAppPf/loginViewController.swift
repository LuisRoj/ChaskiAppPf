//
//  loginViewController.swift
//  ChaskiAppPf
//
//  Created by Luis on 12/12/24.
//

import UIKit
import FirebaseAuth

class loginViewController: UIViewController {
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    
    @IBAction func loginButtonTapped(_ sender: UIButton) {
        // Validar que los campos no estén vacíos
                guard let email = emailTextField.text, !email.isEmpty,
                      let password = passwordTextField.text, !password.isEmpty else {
                    showAlert(message: "Por favor, completa todos los campos.")
                    return
                }

                // Intentar iniciar sesión con Firebase Auth
                Auth.auth().signIn(withEmail: email, password: password) { authResult, error in
                    if let error = error {
                        self.showAlert(message: "Error al iniciar sesión: \(error.localizedDescription)")
                        return
                    }

                    // Si la sesión es exitosa, navegar a la pantalla principal
                    self.navigateToMainScreen()
                }
            }

            // Método para mostrar alertas
            func showAlert(message: String) {
                let alert = UIAlertController(title: "Atención", message: message, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                present(alert, animated: true, completion: nil)
            }

            // Navegar a la pantalla principal
            func navigateToMainScreen() {
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                if let mainTabBarController = storyboard.instantiateViewController(withIdentifier: "MainTabBarController") as? UITabBarController {
                    mainTabBarController.modalPresentationStyle = .fullScreen
                    self.present(mainTabBarController, animated: true, completion: nil)
                }
            }
        }
