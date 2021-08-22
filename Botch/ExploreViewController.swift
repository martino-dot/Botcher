//
//  ExploreViewController.swift
//  Botch
//
//  Created by Martin Velev on 11/29/20.
//

import UIKit

class ExploreViewController: UITableViewController {
    
    
    private var exploreCategories = [ExploreCategory]()
    var categories = Category.fetchAll()

    public override func viewDidLoad() {
        super.viewDidLoad()
        let decoder = JSONDecoder()
        guard let json = readLocalFile(forName: "data") else { print("error code afka39432"); return }
        do {
            let cats = try decoder.decode(ExploreCategories.self, from: json)
            self.exploreCategories = cats.categories
            self.tableView.reloadData()
        } catch {
            print("error code: 10c9bj3msdf")
        }
    }

    private func readLocalFile(forName name: String) -> Data? {
        do {
            if let bundlePath = Bundle.main.path(forResource: name,
                                                 ofType: "json"),
                let jsonData = try String(contentsOfFile: bundlePath).data(using: .utf8) {
                return jsonData
            }
        } catch {
            print(error)
        }
        
        return nil
    }
    

}
extension ExploreViewController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.exploreCategories.count
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
        {
            if segue.destination is ResultsViewController
            {
                if let vc = segue.destination as? ResultsViewController {
                    if segue.identifier == "showExploreResults" {
                        if let indexPath = self.tableView.indexPathForSelectedRow {
                            let selectedRow = indexPath.row
                            vc.customArray = self.exploreCategories[selectedRow].Results
                            vc.topic = "showCustomResults"
                        }
                        
                    }
                }
            }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "ExploreTableViewCell") as? ExploreTableViewCell else { return UITableViewCell() }
        cell.exploreButton.setTitle(self.exploreCategories[indexPath.row].Title, for: .normal)
        let beforeColor = exploreCategories[indexPath.row].Title_Color
        let titleColor = UIColor(beforeColor)
        let beforeBackgroundColor = exploreCategories[indexPath.row].Background_Color
        cell.exploreButton.setTitleColor(titleColor, for: .normal)
        cell.exploreButton.backgroundColor = UIColor(beforeBackgroundColor)
        return cell
    }
    
    override func tableView(_ tableView: UITableView,
                     trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration?
      {
        let addAction = UIContextualAction(style: .normal, title:  "Add", handler: { (ac:UIContextualAction, view:UIView, success:(Bool) -> Void) in
            let date = Date()
            let category = Category(context: AppDelegate.viewContext)
            category.title = self.exploreCategories[indexPath.row].Title
            category.results = self.exploreCategories[indexPath.row].Results
            category.modificationDate = date
            category.titleColor = self.exploreCategories[indexPath.row].Title_Color
            category.titleBackground = self.exploreCategories[indexPath.row].Background_Color
            try? AppDelegate.viewContext.save()
            DispatchQueue.main.async {
                self.tableView.reloadData()
                self.tabBarController?.selectedIndex = 0
            }
       })
       addAction.backgroundColor = .blue
       return UISwipeActionsConfiguration(actions: [addAction])
      }
    
    class ExploreCategories: Codable {
        let categories: [ExploreCategory]
        init(categories: [ExploreCategory]) {
            self.categories = categories
        }
    }
    class ExploreCategory: Codable {
        let Title: String?
        let Results: [String]
        let Title_Color: String
        let Background_Color: String
        init(Title: String?, Results: [String], Title_Color: String, Background_Color: String) {
            self.Title = Title
            self.Results = Results
            self.Title_Color = Title_Color
            self.Background_Color = Background_Color
        }
    }
}
