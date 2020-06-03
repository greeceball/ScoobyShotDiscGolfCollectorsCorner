//
//  MyCollectionTableViewController.swift
//  CollectorsCorner
//
//  Created by Colby Harris on 5/21/20.
//  Copyright © 2020 Colby_Harris. All rights reserved.
//

import UIKit

class MyCollectionTableViewController: UITableViewController {
    
    //MARK: - Properties and outlets
    @IBOutlet var myCollectionTableView: UITableView!
    var myCollection: [Disc] = []
    var refresh: UIRefreshControl = UIRefreshControl()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadMyCollection()
        setupViews()
    }
    
    func setupViews() {
        tableView.delegate = self
        tableView.dataSource = self
        refresh.attributedTitle = NSAttributedString(string: "Pull to update My Collection")
        refresh.addTarget(self, action: #selector(loadMyCollection), for: .valueChanged)
        tableView.addSubview(refresh)
    }
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return myCollection.count
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "discCell", for: indexPath) as? DiscCell else { return UITableViewCell() }
        
        let disc = myCollection[indexPath.row]
        cell.setDisc(disc: disc)
        
        return cell
    }
    
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {
        
    }
    
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    
    
}

extension MyCollectionTableViewController {
    
    @objc func loadMyCollection() {
        CollectionController.shared.fetchCollection(for: UserDefaults.standard.value(forKey: "userID") as! String) { (result) in
            switch result {
                
            case .success(let collection):
                guard let collection = collection else { return }
                guard let discs = collection.discs else { return }
                for disc in discs {
                    DiscController.shared.loadDisc(discId: disc) { (result) in
                        switch result {
                            
                        case .success(let disc):
                            guard let disc = disc else { return }
                            self.myCollection.append(disc)
                        case .failure(let error):
                            print(error.localizedDescription)
                        }
                    }
                }
                
                print("collection loaded")
                self.updateViews()
            case .failure(let error):
                print(error.errorDescription)
                
            }
        }
    }
    
    func updateViews() {
        DispatchQueue.main.async {
            self.tableView.reloadData()
            self.refreshControl?.endRefreshing()
        }
    }
}
