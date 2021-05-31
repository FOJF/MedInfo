//
//  DetailTakeMedicineViewController.swift
//  MedInfo
//
//  Created by JJW on 2021/05/28.
//

import UIKit

class DetailTakeMedicineViewController: UIViewController {
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var etcTextView: UITextView!
    
    var takeMedicine: TakeMedicine?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        etcTextView.layer.borderWidth = 1.0
        etcTextView.layer.cornerRadius = 5
        etcTextView.layer.borderColor = UIColor.systemGray5.cgColor
        
        nameLabel.text = takeMedicine?.name
        timeLabel.text = takeMedicine?.time
        etcTextView.text = takeMedicine?.etc
    }
}
