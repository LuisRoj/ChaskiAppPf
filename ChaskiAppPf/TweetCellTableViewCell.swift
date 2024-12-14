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
    
    func configureCell(with tweet: Tweet) {
            print("Configuring cell with tweet: \(tweet)")

            // Configurar texto de las etiquetas
            userDisplayNameLabel.text = tweet.userDisplayName ?? "Unknown"
            usernameLabel.text = tweet.username ?? "Unknown"
            contentLabel.text = tweet.content

            // Cargar imagen de perfil
            if let profileImageURL = tweet.profileImageURL {
                loadImage(from: profileImageURL) { image in
                    self.profileImageView.image = image
                }
            } else {
                profileImageView.image = nil
            }

            // Cargar imagen del tuit
            if let tweetImageURL = tweet.imageURL {
                print("Cargando imagen del tuit desde: \(tweetImageURL)") // Log de depuración
                tweetImageView.isHidden = false // Mostrar imageView
                tweetImageView.backgroundColor = .green // Agregar color de fondo temporal
                loadImage(from: tweetImageURL) { image in
                    if let image = image {
                        self.tweetImageView.image = image
                        print("Imagen cargada con éxito")
                    } else {
                        print("Error al cargar la imagen del tuit")
                        self.tweetImageView.isHidden = true // Ocultar en caso de error
                    }
                }
            } else {
                tweetImageView.isHidden = true // Si no hay URL de imagen, ocultamos el ImageView
            }
        }

        // Método para cargar imágenes de una URL
        private func loadImage(from urlString: String, completion: @escaping (UIImage?) -> Void) {
            guard let url = URL(string: urlString) else {
                print("URL no válida: \(urlString)")
                completion(nil)
                return
            }
            
            URLSession.shared.dataTask(with: url) { (data, response, error) in
                if let error = error {
                    print("Error al cargar la imagen: \(error.localizedDescription)")
                    completion(nil)
                    return
                }

                guard let data = data, let image = UIImage(data: data) else {
                    print("Error al convertir los datos a imagen")
                    completion(nil)
                    return
                }
                
                DispatchQueue.main.async {
                    completion(image)
                }
            }.resume()
        }
    }
