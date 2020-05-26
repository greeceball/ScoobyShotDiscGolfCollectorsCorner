//
//  CollectionsTableViewCell.swift
//  CollectorsCorner
//
//  Created by Colby Harris on 5/25/20.
//  Copyright © 2020 Colby_Harris. All rights reserved.
//

import UIKit

class CollectionsCell: UITableViewCell {
    @IBOutlet weak var collectionImageView: UIImageView!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var stateLabel: UILabel!
    @IBOutlet weak var yearsCollectingLabel: UILabel!
    @IBOutlet weak var numberOfDiscsLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
