//
//  DiscCustomTableViewCell.swift
//  CollectorsCorner
//
//  Created by Colby Harris on 5/25/20.
//  Copyright © 2020 Colby_Harris. All rights reserved.
//

import UIKit

class DiscCell: UITableViewCell {

    //MARK: - Outlets and Properties
    @IBOutlet weak var discImageView: UIImageView!
    @IBOutlet weak var brandLabel: UILabel!
    @IBOutlet weak var moldLabel: UILabel!
    @IBOutlet weak var colorLabel: UILabel!
    @IBOutlet weak var plasticLabel: UILabel!
    @IBOutlet weak var runLabel: UILabel!
    @IBOutlet weak var flightPathLabel: UILabel!
    
    var disc: Disc?
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func setDisc(disc: Disc) {
        self.disc = disc
        updateUI()
    }
    
    func updateUI() {
        guard let disc = disc else { return }
        
        discImageView.image = disc.discImage
        brandLabel.text = disc.brand
        moldLabel.text = disc.mold
        colorLabel.text = disc.color
        plasticLabel.text = disc.plastic
        runLabel.text = String(describing: disc.run)
        flightPathLabel.text = disc.flightPath
    }
}
