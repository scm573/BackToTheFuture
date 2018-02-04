//
//  MemorialTableViewController.swift
//  BackToTheFuture
//
//  Created by Wu, Qifan | Keihan | ECID on 2018/01/26.
//  Copyright © 2018 Wu, Qifan | Keihan | ECID. All rights reserved.
//

import UIKit
import Kingfisher
import CoreData

class MemorialTableViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    var fetchedResultsController : NSFetchedResultsController<NSFetchRequestResult>? {
        didSet {
            fetchedResultsController?.delegate = self
            executeSearch()
            tableView.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let fr = NSFetchRequest<NSFetchRequestResult>(entityName: "Memorial")
        fr.sortDescriptors = [NSSortDescriptor(key: "newPhotoTime", ascending: false)]
        fr.returnsObjectsAsFaults = false
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fr, managedObjectContext: AppDelegate.shared.stack.context, sectionNameKeyPath: nil, cacheName: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tabBarController?.tabBar.isHidden = false
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showMemorial" {
            let vc = segue.destination as! MemorialViewController
            let indexPath = sender as! IndexPath
            let memorial = fetchedResultsController?.object(at: indexPath) as? Memorial
            vc.memorial = memorial
        }
    }
    
    private func executeSearch() {
        if let fc = fetchedResultsController {
            do {
                try fc.performFetch()
            } catch let e as NSError {
                print("Error while trying to perform a search: \n\(e)\n\(String(describing: fetchedResultsController))")
            }
        }
    }
}

extension MemorialTableViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let fc = fetchedResultsController {
            return fc.sections![section].numberOfObjects
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! MemorialTableViewCell
        
        let memorial = fetchedResultsController?.object(at: indexPath) as? Memorial
        
        if let oldImageUrl = memorial?.oldPhotoUrl,
            let newImageData = memorial?.newPhotoData,
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
        performSegue(withIdentifier: "showMemorial", sender: indexPath)
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            performUIUpdatesOnMain {
                do {
                    let memorial = self.fetchedResultsController?.object(at: indexPath) as? Memorial
                    AppDelegate.shared.stack.context.delete(memorial!)
                    try AppDelegate.shared.stack.context.save()
                    tableView.reloadData()
                }
                catch {
                    fatalError("Failed when deleting a memorial.")
                }
            }
        }
    }
}

extension MemorialTableViewController: NSFetchedResultsControllerDelegate {
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.beginUpdates()
    }
    
    func controller(controller: NSFetchedResultsController<NSFetchRequestResult>, didChangeSection sectionInfo: NSFetchedResultsSectionInfo, atIndex sectionIndex: Int, forChangeType type: NSFetchedResultsChangeType) {
        let index = IndexSet(integer: sectionIndex)
        switch type {
        case .insert:
            tableView.insertSections(index, with: .fade)
        case .delete:
            tableView.deleteSections(index, with: .fade)
        default:
            // irrelevant in our case
            break
        }
    }
    
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any,at indexPath: IndexPath?, for type: NSFetchedResultsChangeType,newIndexPath: IndexPath?) {
        
        switch type {
        case .insert:
            tableView.insertRows(at: [newIndexPath!], with: .fade)
        case .delete:
            tableView.deleteRows(at: [indexPath!], with: .fade)
        case .update:
            tableView.reloadRows(at: [indexPath!], with: .fade)
        case .move:
            tableView.deleteRows(at: [indexPath!], with: .fade)
            tableView.insertRows(at: [newIndexPath!], with: .fade)
        }
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.endUpdates()
    }
}
