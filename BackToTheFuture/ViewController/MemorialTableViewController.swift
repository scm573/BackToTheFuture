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
    
    var memorials: [Memorial]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let predicate = NSPredicate(value: true)
        queryDataOf(entityName: "Memorial", predicate: predicate) { fetchedObjects in
            performUIUpdatesOnMain {
                self.memorials = fetchedObjects as? [Memorial]
                self.tableView.reloadData()
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
        guard let memorials = memorials else { return cell }
        let oldImageUrl = memorials[indexPath.row].oldPhotoUrl
        cell.oldImageView.kf.setImage(with: URL(string: oldImageUrl!))
        cell.newImageView.image = UIImage(data: memorials[indexPath.row].newPhotoData!) //TODO: EXC_BAD_ACCESS here. Same even if using NSFetchedResultsController
        cell.oldTimeLabel.text = memorials[indexPath.row].oldPhotoTime
        cell.newTimeLabel.text = memorials[indexPath.row].newPhotoTime
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "showMemorial", sender: indexPath.row)
    }
}
