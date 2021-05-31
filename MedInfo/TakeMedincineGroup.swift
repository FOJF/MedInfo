//
//  TakeMedincineGroup.swift
//  MedInfo
//
//  Created by JJW on 2021/05/27.
//

import Foundation

class TakeMedicineGroup {
    var takeMedicines = [TakeMedicine]()
    
    init() {
        TakeMedicine.count = 0
    }
    
    func count() -> Int {
        return takeMedicines.count
    }
    
    func addTakeMedicine(takeMedicine: TakeMedicine) {
        takeMedicines.append(takeMedicine)
    }
    
    func modifyTakeMedicine(takeMedicine: TakeMedicine, index: Int) {
        takeMedicines[index] = takeMedicine
    }
    func removeTakeMedicine(index: Int) {
        takeMedicines.remove(at: index)
    }
}
