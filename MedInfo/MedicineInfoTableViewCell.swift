//
//  MedicineInfoTableViewCell.swift
//  MedInfo
//
//  Created by JJW on 2021/05/26.
//

import UIKit

class MedicineInfoTableViewCell: UITableViewCell {

    @IBOutlet weak var titleTextLabel: UILabel!
    @IBOutlet weak var customDetailTextLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

}
