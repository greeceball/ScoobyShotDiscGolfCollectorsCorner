//
//  CreateDiscViewController.swift
//  CollectorsCorner
//
//  Created by Colby Harris on 5/25/20.
//  Copyright © 2020 Colby_Harris. All rights reserved.
//

import UIKit
import CloudKit

class CreateDiscViewController: UIViewController {
    
    //MARK: - Outlets and Properties
    @IBOutlet weak var discImageContainerView: UIView!
    @IBOutlet weak var brandTextField: UITextField!
    @IBOutlet weak var moldTextField: UITextField!
    @IBOutlet weak var colorTextField: UITextField!
    @IBOutlet weak var plasticTextField: UITextField!
    @IBOutlet weak var runTextField: UITextField!
    @IBOutlet weak var flightPathPickerView: UIPickerView!
    
    var image: UIImage?
    var currentUser: User?
    var flightPathText: String = ""
    var pickerData: [[Float]] = [[]]
    
    var speedPickerData: [String] = ["--","1","2","3","4","5","6","7","8","9","10","11","12","13","14","15"]
    var glidePickerData: [String] = ["--","1","2","3","4","5","6","7"]
    var turnPickerData: [String] = ["--","1","0.5","0","-0.5","-1","-1.5","-2","-2.5","-3","-3.5","-4","-4.5","-5"]
    var fadePickerData: [String] = ["--","0","1.5","2","2.5","3","3.5","4","4.5","5"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configView()
        loadCurrentUser()
        //loadPickerData()
    }
    
    func loadCurrentUser() {
        self.currentUser = TabBarController.shared.user
    }
    
    //MARK: - Actions
    @IBAction func saveButtonTapped(_ sender: Any) {
        var collectionFromCK: [Collection] = []
        var collectionToUpdate: [CKRecord.ID] = []
        guard let brand = brandTextField.text, !brand.isEmpty, let mold = moldTextField.text, !mold.isEmpty, let discImage = self.image else { return }
        let run = Int(runTextField.text!)
        
        let newDisc = DiscController.shared.createDisc(brand: brand, mold: mold, color: colorTextField.text, plastic: plasticTextField.text, flightPath: flightPathText, run: run, discImage: discImage)
        
        CollectionController.shared.fetchCollection(for: UserDefaults.standard.value(forKey: "userID") as! String) { (result) in
            switch result {
                
            case .success(let collection):
                
                guard let collection = collection else { return }
                guard let discs = collection.discs else { return }
                
                collectionToUpdate = discs
                collectionToUpdate.append(newDisc.discCKRecordID)
                collection.discs = collectionToUpdate
                print(collection)
                
                CollectionController.shared.updateCollection(collection) { (result) in
                    
                    switch result {
                        
                    case .success(_):
                        break
                    case .failure(let error):
                        print(error.localizedDescription)
                    }
                }
                
            case .failure(let error):
                print(error.errorDescription)
            }
        } 
        
        DiscController.shared.saveDisc(disc: newDisc){ result in
            DispatchQueue.main.async {
                self.navigationController?.popViewController(animated: true)
            }
        }
    }
        
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toPhotoPickerVC" {
            let destinationVC = segue.destination as? PhotoPickerViewController
            destinationVC?.delegate = self
        }
    }
}

extension CreateDiscViewController: PhotoSelectorDelegate {
    func photoPickerSelected(image: UIImage) {
        self.image = image
    }
}

extension CreateDiscViewController: UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate {
    
    func configView() {
        flightPathPickerView.dataSource = self
        flightPathPickerView.delegate = self
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 4
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if component == 0 {
            return speedPickerData.count
        } else if component == 1 {
            return glidePickerData.count
        } else if component == 2 {
            return turnPickerData.count
        }
        return fadePickerData.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if component == 0 {
            return speedPickerData[row]
        } else if component == 1 {
            return glidePickerData[row]
        } else if component == 2 {
            return turnPickerData[row]
        }
        return fadePickerData[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        var speed: String = speedPickerData[pickerView.selectedRow(inComponent: 0)].description
        var glide: String = glidePickerData[pickerView.selectedRow(inComponent: 1)].description
        var turn: String = turnPickerData[pickerView.selectedRow(inComponent: 2)].description
        var fade: String = fadePickerData[pickerView.selectedRow(inComponent: 3)].description
        
        self.flightPathText = (speed + " | " + glide + " | " + turn + " | " + fade)
        print("didSelectRow")
    }
}
