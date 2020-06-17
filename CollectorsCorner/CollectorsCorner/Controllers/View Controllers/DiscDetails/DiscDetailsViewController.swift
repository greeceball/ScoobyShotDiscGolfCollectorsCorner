//
//  DiscDetailsViewController.swift
//  CollectorsCorner
//
//  Created by Colby Harris on 5/26/20.
//  Copyright © 2020 Colby_Harris. All rights reserved.
//

import UIKit

class DiscDetailsViewController: UIViewController {
    
    
    //MARK: - Properties and outlets
    @IBOutlet weak var discImageView: UIImageView!
    @IBOutlet weak var brandLabel: UILabel!
    @IBOutlet weak var moldLabel: UILabel!
    @IBOutlet weak var colorLabel: UILabel!
    @IBOutlet weak var plasticLabel: UILabel!
    @IBOutlet weak var flightPathLabel: UILabel!
    @IBOutlet weak var runLabel: UILabel!

    var discToBeLoaded: Disc?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadViews(disc: discToBeLoaded)
        // Do any additional setup after loading the view.
    }

    func loadViews(disc: Disc?) {
        var loadedDisc: Disc?
        guard let disc = disc else { return }
        DiscController.shared.loadDisc(discId: disc.discCKRecordID) { (result) in
            switch result {
                
            case .success(let disc):
                guard let disc = disc else { return }
                loadedDisc = disc
            case .failure(_):
                print("error loading disc")
            }
        }
        
        guard let currentDisc = loadedDisc else { return }
        discImageView.image = currentDisc.discImage
        brandLabel.text = currentDisc.brand
        moldLabel.text = currentDisc.mold
        colorLabel.text = currentDisc.color
        plasticLabel.text = currentDisc.plastic
        flightPathLabel.text = currentDisc.flightPath
        runLabel.text = String(describing: currentDisc.run)
    }
}
