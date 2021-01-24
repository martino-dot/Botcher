//
//  CustomCategoriesViewController.swift
//  Botch
//
//  Created by Martin Velev on 8/20/20.
//

import UIKit
import CloudKit
import CoreData
import SystemConfiguration
import Reachability

class CustomCategoriesViewController: UIViewController, UISearchResultsUpdating {
    
    
    func updateSearchResults(for searchController: UISearchController) {
        let searchText = searchController.searchBar.text
        if !(searchController.searchBar.text?.isEmpty ?? false) {
            var predicate: NSPredicate = NSPredicate()
            predicate = NSPredicate(format: "title contains[cd] %@", searchText!)
            guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
            let managedObjectContext = appDelegate.persistentContainer.viewContext
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName:"Category")
            fetchRequest.predicate = predicate
            do {
                categories = try managedObjectContext.fetch(fetchRequest) as! [Category]
            } catch let error as NSError {
                print("Could not fetch. \(error)")
            }
        } else {
            categories = Category.fetchAll()
        }
        self.table.reloadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        categories = Category.fetchAll()
        self.table.reloadData()
    }
    
    @IBOutlet var table: UITableView!
    
    var categories = Category.fetchAll()
    var timer = Timer()
    var resultSearchController = UISearchController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        table.delegate = self
        table.dataSource = self
        resultSearchController = ({
            let controller = UISearchController(searchResultsController: nil)
            controller.searchResultsUpdater = self
            controller.searchBar.sizeToFit()
            table.tableHeaderView = controller.searchBar
            return controller
        })()
        self.categories = Category.fetchAll()
    }
    
    
    
    func random() -> String {
        var result = ""
        repeat {
            result = String(format:"%04d", arc4random_uniform(10000) )
        } while result.count < 4 || Int(result)! < 1000
        return result
    }
    // showCustomResults
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
        {
            if segue.destination is ResultsViewController
            {
                if let vc = segue.destination as? ResultsViewController {
                    if segue.identifier == "showCustomResults" {
                        if let indexPath = table.indexPathForSelectedRow{
                            let selectedRow = indexPath.row
                            guard let array = categories[selectedRow].results else { return }
                            vc.customArray = array
                            vc.topic = "showCustomResults"
                        }
                        
                    }
                }
            }
    }
    @IBAction func didTapAdd() {
        guard let vc = storyboard?.instantiateViewController(identifier: "add") as? AddViewController else { return }
        vc.title = "New Category"
        vc.navigationItem.largeTitleDisplayMode = .never
        vc.completion = { title, results, backgroundColor, titleColor in
            let resultarray = results.components(separatedBy: ",")
            let identifier = String("id_\(title)_\(self.random())")
            let date = Date()
            let category = Category(context: AppDelegate.viewContext)
            category.title = title
            category.results = resultarray
            category.identifier = identifier
            category.modificationDate = date
            category.titleColor = titleColor
            category.titleBackground = backgroundColor
            try? AppDelegate.viewContext.save()
            self.categories = Category.fetchAll()
            DispatchQueue.main.async {
                self.table.reloadData()
            }
            DispatchQueue.main.async {
                self.navigationController?.popToRootViewController(animated: true)
            }
        }
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func didTapBack() {
        self.dismiss(animated: true, completion: nil)
    }

}
extension CustomCategoriesViewController: UITableViewDelegate {
    

    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        table.deselectRow(at: indexPath, animated: true)
    }

     func tableView(_ tableView: UITableView,
                      trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration?
       {
           // Write action code for the trash
           let deleteAction = UIContextualAction(style: .destructive, title:  "Delete", handler: { (ac:UIContextualAction, view:UIView, success:(Bool) -> Void) in
            let appDel:AppDelegate = UIApplication.shared.delegate as! AppDelegate
            appDel.persistentContainer.viewContext.delete(self.categories[indexPath.row] as NSManagedObject)
            self.categories.remove(at: indexPath.row)
            try? appDel.persistentContainer.viewContext.save()
            DispatchQueue.main.async {
                self.table.deleteRows(at: [indexPath], with: .left)
            }
           })
        // Write action code for the More
        let editAction = UIContextualAction(style: .normal, title:  "Edit", handler: { (ac:UIContextualAction, view:UIView, success:(Bool) -> Void) in
         guard let vc = self.storyboard?.instantiateViewController(identifier: "add") as? AddViewController else { return }
         vc.title = "Edit Category"
         vc.isItBeingEdited = true
         vc.theExsistingTitle = self.categories[indexPath.row].title ?? ""
         vc.theExsistingResults = self.categories[indexPath.row].results?.joined(separator: ",") ?? ""
         vc.titleColor = self.categories[indexPath.row].titleColor ?? "#ffffff"
         vc.backgroundColor = self.categories[indexPath.row].titleBackground ?? "#000000"
         vc.navigationItem.largeTitleDisplayMode = .never
         vc.completion = { title, results, backgroundColor, titleColor in
             let resultarray = results.split(separator: ",").compactMap({String($0)})
             let date = Date()
             let theNewCategory = self.categories[indexPath.row]
             theNewCategory.title = title
             theNewCategory.results = resultarray
             theNewCategory.modificationDate = date
             theNewCategory.titleColor = titleColor
             theNewCategory.titleBackground = backgroundColor
             try? AppDelegate.viewContext.save()
             self.categories = Category.fetchAll()
             DispatchQueue.main.async {
                 self.table.reloadData()
             }
             DispatchQueue.main.async {
                 self.navigationController?.popToRootViewController(animated: true)
             }
         }
         self.navigationController?.pushViewController(vc, animated: true)
         success(true)
        })
        editAction.backgroundColor = .orange
           deleteAction.backgroundColor = .red
        /*if #available(iOS 14.0, *) {
        let shareAction = UIContextualAction(style: .normal, title: "Share", handler: { (ac:UIContextualAction, view:UIView,success:(Bool) -> Void) in
              let reachability = try? Reachability()
                let persistentStoreDescriptions = NSPersistentStoreDescription()

                let containerIdentifier = persistentStoreDescriptions.cloudKitContainerOptions!.containerIdentifier
                persistentStoreDescriptions.cloudKitContainerOptions = NSPersistentCloudKitContainerOptions(containerIdentifier: containerIdentifier)
                persistentStoreDescriptions.cloudKitContainerOptions?.databaseScope = .shared
                
                reachability?.whenReachable = { reachability in
                    if reachability.connection == .wifi {
                        
                    } else {
                        // Add method to share cell
                    }
              }
            
                reachability?.whenUnreachable = { _ in
                    self.showNoInternet()
                }
            
                do {
                    try reachability?.startNotifier()
                } catch {
                    self.showNoInternet()
                }
            })
        
        shareAction.backgroundColor = .blue
            return UISwipeActionsConfiguration(actions: [deleteAction, editAction, shareAction])
        } else {
            return UISwipeActionsConfiguration(actions: [deleteAction, editAction])
        }*/
        return UISwipeActionsConfiguration(actions: [deleteAction, editAction])
       }
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }

}
extension CustomCategoriesViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.categories.count
    }
    
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as? CustomCategoryTableViewCell
        let title = categories[indexPath.row].title
        cell?.customButton.setTitle(title, for: .normal)
        guard let beforeColor = categories[indexPath.row].titleColor else { return cell! }
        let titleColor = UIColor(beforeColor)
        guard let beforeBackgroundColor = categories[indexPath.row].titleBackground else { return cell! }
        cell?.customButton.setTitleColor(titleColor, for: .normal)
        cell?.customButton.backgroundColor = UIColor(beforeBackgroundColor)
        return cell!
    }
    func showNoInternet() {
       
            // create the alert
        let alert = UIAlertController(title: "Error", message: "Connect to internet to share categories!", preferredStyle: UIAlertController.Style.alert)

            // add an action (button)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
        DispatchQueue.main.async {
            // show the alert
            self.present(alert, animated: true, completion: nil)
        }
    }
}
