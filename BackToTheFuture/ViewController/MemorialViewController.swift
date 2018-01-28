//
//  MemorialViewController.swift
//  BackToTheFuture
//
//  Created by Wu, Qifan | Keihan | ECID on 2018/01/26.
//  Copyright © 2018 Wu, Qifan | Keihan | ECID. All rights reserved.
//

import UIKit
import CoreData

class MemorialViewController: UIViewController {
    
    @IBOutlet weak var oldImageView: UIImageView!
    @IBOutlet weak var newImageView: UIImageView!
    @IBOutlet weak var actionButton: UIBarButtonItem!
    
    var memorial: Memorial?
    
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
        
        guard let memorial = memorial else { return }
        oldImageView.kf.setImage(with: URL(string: memorial.oldPhotoUrl!))
        
        if let newPhotoData = memorial.newPhotoData {
            newImageViewState = .set
            newImageView.image = UIImage(data: newPhotoData)
        } else {
            newImageViewState = .notSet
            presentCameraController()
        }
    }
    
    @objc func action() {
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
            memorial?.newPhotoData = UIImageJPEGRepresentation(image, 1)
            memorial?.newPhotoTime = getCurrentTimeString()
        }
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
}

extension MemorialViewController {
    fileprivate func getCurrentTimeString() -> String {
        let dateFormatter: DateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let date = Date()
        return dateFormatter.string(from: date)
    }
}
