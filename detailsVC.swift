//  detailsVC.swift
//  Artbook
//
//  Created by Okan Karaman on 8.10.2024.
//

import UIKit
import CoreData

class detailsVC: UIViewController, UIImagePickerControllerDelegate , UINavigationControllerDelegate {
    
    
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var imageview: UIImageView!
    @IBOutlet weak var yearText: UITextField!
    @IBOutlet weak var artistText: UITextField!
    @IBOutlet weak var nameText: UITextField!
    
    var chosenPaintingName = ""
    var chosenpaintingID : UUID?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if chosenPaintingName != "" {
            saveButton.isHidden = true
            
            // Get the painting info by CoreData
            
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            let context = appDelegate.persistentContainer.viewContext
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Paintings")
            
            let idString = chosenpaintingID?.uuidString
            
            fetchRequest.predicate = NSPredicate(format: "id = %@", idString!)
            
            fetchRequest.returnsObjectsAsFaults = false
            
            do {
                let results = try context.fetch(fetchRequest)
                if results.count > 0 {
                    for result in results as! [NSManagedObject] {
                        
                     
                        
                        if let name = result.value(forKey: "name") as? String {
                            nameText.text = name
                        }
                        
                        if let artist = result.value(forKey: "artist") as? String {
                            artistText.text = artist
                        }
                        
                        if let year = result.value(forKey: "year") as? Int {
                            yearText.text = String(year)
                        }
                        
                        if let imageData = result.value(forKey: "image") as? Data {
                            let image = UIImage(data: imageData)
                            imageview.image = image
                        }
                    }
                }
            } catch {
                print("Error")
            }
        } else {
            saveButton.isHidden = false
            nameText.text = ""
            artistText.text = ""
            yearText.text = ""
            saveButton.isEnabled = false
            imageview.image = UIImage(named: "select")
        }
        
        
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        view.addGestureRecognizer(gestureRecognizer)
        
        imageview.isUserInteractionEnabled = true
        let imageTapRecognizer = UITapGestureRecognizer(target: self, action: #selector(selectImage))
        imageview.addGestureRecognizer(imageTapRecognizer)
        

    }
    
    @objc func hideKeyboard(){
        view.endEditing(true)
    }
    
    @objc func selectImage(){
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .photoLibrary
        picker.allowsEditing = true
        present(picker,animated: true,completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        imageview.image = info[.originalImage] as? UIImage
        saveButton.isEnabled = true
        self.dismiss(animated: true)
    }
    
    @IBAction func saveButton(_ sender: Any) {
        print("clicked the save button")
        
        //Manage Core
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        //Entitiy
        let newPainting = NSEntityDescription.insertNewObject(forEntityName: "Paintings", into: context)
        
        if nameText.text! == "" {
            makeAlert(title: "Error", message: "Please give a name")
        }
        
        
        
        newPainting.setValue(nameText.text!, forKey: "name")
        newPainting.setValue(artistText.text!, forKey: "artist")
        
        if let year = Int(yearText.text!) {
            newPainting.setValue(year, forKey: "year")
        }
        newPainting.setValue(UUID(), forKey: "id")
        
        let data = imageview.image!.jpegData(compressionQuality: 0.5)
        newPainting.setValue(data, forKey: "image")
        
        // Save
        do {
            try context.save()
            print("Entitiy Saved")
        }
        catch {
            print("Something happened while tring to save entity")
        }
        
        // back to the tableview
        self.navigationController?.popViewController(animated: true)
        
        //Broadcast "newData" after save entity
        NotificationCenter.default.post(name: NSNotification.Name("newData"), object: nil)
        
    }
    
    func makeAlert(title: String, message: String) {
        
        let alert = UIAlertController(title: title, message: message , preferredStyle: .alert)
        let okButton = UIAlertAction(title: "OK", style: .default)
        alert.addAction(okButton)
        self.present(alert, animated: true)
        
    }
    
}
