//
//  MemorialViewController.swift
//  BackToTheFuture
//
//  Created by Wu, Qifan | Keihan | ECID on 2018/01/26.
//  Copyright © 2018 Wu, Qifan | Keihan | ECID. All rights reserved.
//

import UIKit

class MemorialViewController: UIViewController {
    
    @IBOutlet weak var oldImageView: UIImageView!
    @IBOutlet weak var newImageView: UIImageView!
    @IBOutlet weak var actionButton: UIBarButtonItem!
    
    var oldImageUrl: String?
    var newImageViewState = NewImageViewState.notSet {
        didSet {
            let item = newImageViewState == .set ? UIBarButtonSystemItem.trash : UIBarButtonSystemItem.camera
            let actionButton =  UIBarButtonItem(barButtonSystemItem: item, target: self, action: #selector(action))
            self.navigationItem.rightBarButtonItem = actionButton
        }
    }
    enum NewImageViewState {
        case set
        case notSet
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tabBarController?.tabBar.isHidden = true
        newImageViewState = .notSet
        
        if let oldImageUrl = oldImageUrl {
            oldImageView.kf.setImage(with: URL(string: oldImageUrl))
            presentCameraController()
        }
    }
    
    @objc func action() {
        if newImageViewState == .set {
            //Delete persisted image data
        }
        presentCameraController()
    }
    
    private func presentCameraController() {
        let pickerController = UIImagePickerController()
        pickerController.delegate = self
        pickerController.sourceType = .camera
        present(pickerController, animated: true, completion: nil)
    }
}

extension MemorialViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            newImageView.image = image
            newImageViewState = .set
        }
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
}
