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
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
