//
//  ViewController.swift
//  PhotoKitDemo
//
//  Created by Pedro Contine on 30/01/21.
//

import UIKit
import PhotoKit

class ViewController: UIViewController {
    
    @IBOutlet weak var imageView: UIImageView!
    private var imagePicker: ImagePicker?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        createImagePicker()
    }
    
    @IBAction func didPressOpenImagePickerButton() {
        imagePicker?.present(in: self)
    }
    
    private func createImagePicker() {
        let mediaSources = [MediaSource(type: .camera, title: "Camera"),
                            MediaSource(type: .photoLibrary, title: "Library"),
                            MediaSource(type: .savedPhotosAlbum, title: "Album")]
        
        imagePicker = ImagePicker(mediaSources: mediaSources, mediaTypes: [.image])
        imagePicker?.delegate = self
    }
}

extension ViewController: ImagePickerDelegate {
    func didSelect(image: UIImage) {
        imageView.image = image
    }
}
