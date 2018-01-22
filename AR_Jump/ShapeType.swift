//
//  ShapeType.swift
//  AR_Jump
//
//  Created by YinjianChen on 2018/1/22.
//  Copyright © 2018年 YinTokey. All rights reserved.
//

import Foundation

enum ShapeType:Int{
    case box = 0
    case cylinder

    
    static func random() -> ShapeType {
        let maxValue = cylinder.rawValue
        let rand = arc4random_uniform(UInt32(maxValue+1))
        return ShapeType(rawValue: Int(rand))!
    }
    
}

