//
//  TakeMedicine.swift
//  MedInfo
//
//  Created by JJW on 2021/05/27.
//

import Foundation

class TakeMedicine {
    static var count: Int = 0
    var name: String?
    var time: String?
    var etc: String?
    
    init(name: String?, time: String?, etc: String?) {
        self.name = name
        self.time = time
        self.etc = etc
    }
    
    convenience init() {
        self.init(name: nil, time: nil, etc: nil)
    }
}
