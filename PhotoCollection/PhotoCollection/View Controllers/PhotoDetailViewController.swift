//
//  PhotoDetailViewController.swift
//  PhotoCollection
//
//  Created by Spencer Curtis on 8/2/18.
//  Copyright © 2018 Lambda School. All rights reserved.
//

import UIKit
import Photos

class PhotoDetailViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    var imageView: UIImageView!
    var titleTextField: UITextField!
    
    var photo: Photo? {
        didSet {
            updateViews()
        }
    }
    
    var photoController: PhotoController?
    var themeHelper: ThemeHelper?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setTheme()
        updateViews()
        setUpSubviews()
    }
    
    // MARK: - UIImagePickerControllerDelegate
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        picker.dismiss(animated: true, completion: nil)
        
        guard let image = info[.originalImage] as? UIImage else { return }
        
        imageView.image = image
    }
    
    // MARK: - Private Methods
    
    @objc private func addImage() {
        
        let authorizationStatus = PHPhotoLibrary.authorizationStatus()
    
        switch authorizationStatus {
        case .authorized:
            presentImagePickerController()
            
        case .notDetermined:
            
            PHPhotoLibrary.requestAuthorization { (status) in
                
                guard status == .authorized else {
                    NSLog("User did not authorize access to the photo library")
                    return
                }
                self.presentImagePickerController()
            }
        default:
            break
        }
    }
    
    @objc private func savePhoto() {
        
        guard let image = imageView.image,
            let imageData = image.pngData(),
            let title = titleTextField.text else { return }
        
        if let photo = photo {
            photoController?.update(photo: photo, with: imageData, and: title)
        } else {
            photoController?.createPhoto(with: imageData, title: title)
        }
        
        navigationController?.popViewController(animated: true)
    }
    
    private func setUpSubviews() {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(imageView)
        
        imageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 50).isActive = true
        imageView.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor, constant: 0).isActive = true
        imageView.heightAnchor.constraint(equalToConstant: 300).isActive = true
        imageView.widthAnchor.constraint(equalToConstant: 300).isActive = true
        
        self.imageView = imageView
        
        let addPhotoButton = UIButton(type: .system)
        addPhotoButton.translatesAutoresizingMaskIntoConstraints = false
        addPhotoButton.setTitle("Add Image", for: .normal)
        addPhotoButton.addTarget(self, action: #selector(addImage), for: .touchUpInside)
        view.addSubview(addPhotoButton)
        
        addPhotoButton.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 50).isActive = true
        addPhotoButton.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor, constant: 0).isActive = true
        
        
        let textField = UITextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.placeholder = "Give this photo a title:"
        view.addSubview(textField)
        
        textField.topAnchor.constraint(equalTo: addPhotoButton.bottomAnchor, constant: 8).isActive = true
        textField.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20).isActive = true
        textField.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20).isActive = true
        
        self.titleTextField = textField
        
        let savePhotoButton = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(savePhoto))
        navigationItem.setRightBarButton(savePhotoButton, animated: true)
        
    }
    
    private func updateViews() {
        
        guard let photo = photo else {
            title = "Create Photo"
            return
        }
        
        title = photo.title
        
        imageView.image = UIImage(data: photo.imageData)
        titleTextField.text = photo.title
    }
    
    private func presentImagePickerController() {
        guard UIImagePickerController.isSourceTypeAvailable(.photoLibrary) else { return }
        
        let imagePicker = UIImagePickerController()
        
        imagePicker.sourceType = .photoLibrary
        imagePicker.delegate = self
        
        present(imagePicker, animated: true, completion: nil)
    }
    
    private func setTheme() {
        guard let themePreference = themeHelper?.themePreference else { return }
        
        var backgroundColor: UIColor!
        
        switch themePreference {
        case "Dark":
            backgroundColor = .lightGray
        case "Blue":
            backgroundColor = UIColor(red: 61/255, green: 172/255, blue: 247/255, alpha: 1)
        default:
            break
        }
        
        view.backgroundColor = backgroundColor
    }
}
