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
    
    var tempOldPhotoUrl: String?
    var tempOldPhotoTime: String?
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
        
        if let memorial = memorial {
            oldImageView.kf.setImage(with: URL(string: (memorial.oldPhotoUrl)!))
            newImageViewState = .set
            newImageView.image = UIImage(data: (memorial.nowPhotoData)!)
        } else {
            oldImageView.kf.setImage(with: URL(string: tempOldPhotoUrl!))
            newImageViewState = .notSet
            presentCameraController()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tabBarController?.tabBar.isHidden = true
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
            
            if memorial == nil {
                memorial = NSManagedObject(entity: NSEntityDescription.entity(forEntityName: "Memorial", in: AppDelegate.shared.stack.context)!, insertInto: AppDelegate.shared.stack.context) as? Memorial
            }
            if let oldPhotoUrl = tempOldPhotoUrl {
                memorial?.oldPhotoUrl = oldPhotoUrl
            }
            if let oldPhotoTime = tempOldPhotoTime {
                memorial?.oldPhotoTime = oldPhotoTime
            }
            memorial?.nowPhotoData = UIImageJPEGRepresentation(image, 1)
            memorial?.nowPhotoTime = getCurrentTimeString()
            try! AppDelegate.shared.stack.context.save()
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
