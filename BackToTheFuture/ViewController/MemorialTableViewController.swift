//
//  MemorialTableViewController.swift
//  BackToTheFuture
//
//  Created by Wu, Qifan | Keihan | ECID on 2018/01/26.
//  Copyright © 2018 Wu, Qifan | Keihan | ECID. All rights reserved.
//

import UIKit
import Kingfisher

class MemorialTableViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    var memorials: [Memorial]? {
        didSet {
            performUIUpdatesOnMain { self.tableView.reloadData() }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let predicate = NSPredicate(value: true)
        CoreDataHelper.queryDataOf(entityName: "Memorial", predicate: predicate) { fetchedObjects in
            performUIUpdatesOnMain {
                self.memorials = fetchedObjects as? [Memorial]
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showMemorial" {
            let vc = segue.destination as! MemorialViewController
            let index = sender as! Int
            vc.memorial = memorials?[index]
        }
    }
}

extension MemorialTableViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return memorials?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! MemorialTableViewCell
        
        let memorial = memorials?[indexPath.row]
        if let oldImageUrl = memorial?.oldPhotoUrl,
            let newImageData = memorial?.newPhotoData, //EXC_BREAKPOINT on main thread
            let oldTime = memorial?.oldPhotoTime,
            let newTime = memorial?.newPhotoTime {
            cell.oldImageView.kf.setImage(with: URL(string: oldImageUrl))
            cell.newImageView.image = UIImage(data: newImageData)
            cell.oldTimeLabel.text = oldTime
            cell.newTimeLabel.text = newTime
        }

        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "showMemorial", sender: indexPath.row)
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            performUIUpdatesOnMain {
                do {
                    let memorial = self.memorials?[indexPath.row]
                    AppDelegate.shared.stack.context.delete(memorial!)
                    try AppDelegate.shared.stack.context.save()
                    self.memorials?.remove(at: indexPath.row)
                    tableView.reloadData()
                }
                catch {
                    fatalError("Failed when deleting a memorial.")
                }
            }
        }
    }
}
