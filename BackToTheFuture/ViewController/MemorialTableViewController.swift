//
//  MemorialTableViewController.swift
//  BackToTheFuture
//
//  Created by Wu, Qifan | Keihan | ECID on 2018/01/26.
//  Copyright © 2018 Wu, Qifan | Keihan | ECID. All rights reserved.
//

import UIKit
import Kingfisher
import DATASource

class MemorialTableViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    lazy var dataSource: DATASource = {
        let request: NSFetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Memorial")
        request.sortDescriptors = [NSSortDescriptor(key: "newPhotoTime", ascending: false)]
        
        let dataSource = DATASource(tableView: self.tableView, cellIdentifier: "cell", fetchRequest: request, mainContext: AppDelegate.shared.dataStack.mainContext, configuration: { cell, item, indexPath in

            let cell = cell as! MemorialTableViewCell
            cell.oldImageView.kf.setImage(with: URL(string: (item.value(forKey: "oldPhotoUrl") as? String)!))
            cell.newImageView.image = UIImage(data: (item.value(forKey: "newPhotoData") as? Data)!)
            cell.oldTimeLabel.text = item.value(forKey: "oldPhotoTime") as? String
            cell.newTimeLabel.text = item.value(forKey: "newPhotoTime") as? String
        })
        
        return dataSource
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = dataSource
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tabBarController?.tabBar.isHidden = false
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showMemorial" {
            let vc = segue.destination as! MemorialViewController
            let indexPath = sender as! IndexPath
            vc.memorial = dataSource.objectAtIndexPath(indexPath) as? Memorial
        }
    }
}

extension MemorialTableViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "showMemorial", sender: indexPath)
    }
}
