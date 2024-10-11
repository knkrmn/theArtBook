//
//  ViewController.swift
//  Artbook
//
//  Created by Okan Karaman on 8.10.2024.
//

import UIKit
import CoreData

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    //Description from UI
    @IBOutlet weak var tableView: UITableView!
    
    //Description varriables
    var nameArray = [String]()  // Here is going to be all the saved names
    var idArray = [UUID]()      // here is going to be all saved id's
    var selectedPaintingName = ""   // This for selected painting from tableView for send data
    var selectedPaintingId : UUID? // This for selected painting ID for send data Segue  - Not init yet
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        // Tableview is going to manage byself
        tableView.delegate = self
        tableView.dataSource = self
        
        // Add butto (+) on the navigation bar
        navigationController?.navigationBar.topItem?.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addButtonClick))
        
        // Get all data from core database
        getData()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        NotificationCenter.default.addObserver(self, selector: #selector(getData),name : NSNotification.Name(rawValue: "newData"),object: nil)
        
    }
    
    // What is going to be happen when click (+) add button
    @objc func addButtonClick(){
        selectedPaintingName = ""
        performSegue(withIdentifier: "toDetailsVC", sender: nil)
    }
    
    // how many row is going to be in tableView
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return nameArray.count
    }
    
    // how ever row is going to looking
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        var content = cell.defaultContentConfiguration()
        content.text = nameArray[indexPath.row]
        cell.contentConfiguration = content
        return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            let context = appDelegate.persistentContainer.viewContext
            
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>.init(entityName: "Paintings")
            
            let idString = idArray[indexPath.row].uuidString
            
            fetchRequest.predicate = NSPredicate(format: "id = %@", idString)
            
            fetchRequest.returnsObjectsAsFaults = true
            
            do {
                let results =  try context.fetch(fetchRequest)
                
                if results.count > 0 {
                    for result in results as! [NSManagedObject] {
                        if let id = result.value(forKey: "id") as? UUID {
                            if id == idArray[indexPath.row] {
                                context.delete(result)
                                nameArray.remove(at: indexPath.row)
                                idArray.remove(at: indexPath.row)
                                self.tableView.reloadData()
                                
                                do {
                                    try context.save()
                                } catch {
                                    print("Save error while deleting")
                                }
                            }
                        }
                    }
                }
            } catch {
                print("Error")
            }
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedPaintingName = nameArray[indexPath.row]
        selectedPaintingId = idArray[indexPath.row]
        
        performSegue(withIdentifier: "toDetailsVC", sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toDetailsVC" {
            let destinationVC = segue.destination as! detailsVC
            destinationVC.chosenPaintingName = selectedPaintingName
            destinationVC.chosenpaintingID = selectedPaintingId
        }
    }
    
    // Get all data from Core
    @objc func getData(){
        
        // Clear all arrays for not show more then 1 times
        nameArray.removeAll(keepingCapacity: false)
        idArray.removeAll(keepingCapacity: false)
        
        // for core connection get permission create a new manager
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        
        // ask to manager for let us go inside of the door of Core and there is a desk named "context"
        let context = appDelegate.persistentContainer.viewContext
        
        // We want a catalog of "Paintings" data
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Paintings")
        
        // Give me all the data
        fetchRequest.returnsObjectsAsFaults = false
        
        do {
            // try to do get all catalog information
            let results = try context.fetch(fetchRequest)
            
            // if more then 1 data come to us
            if results.count > 0 {
                // Data comes in a NSManagedObject array
                for result in results as! [NSManagedObject] {
                    
                    // add name to NameArray
                    if let name = result.value(forKey: "name") as? String {
                        self.nameArray.append(name)
                    }
                    
                    // add id to idArray
                    if let id = result.value(forKey: "id") as? UUID {
                        self.idArray.append(id)
                    }
                }
                // reload data to table after all data loaded to arrays
                self.tableView.reloadData()
            }
            // if something wrong give a message
        } catch {
            print("Some error acured when load data from Core")
            
        }
    }
    
}

