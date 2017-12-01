//
//  Item.swift
//  LGTM
//
//  Created by D on 2017/12/01.
//  Copyright © 2017 Dongri Jin. All rights reserved.
//

import Foundation

class Item: NSObject {
    
    var id: Int64
    var imageURL: NSURL
    
    init(id: Int64, imageURL: NSURL) {
        self.id = id
        self.imageURL = imageURL
        super.init()
    }
    
    func Id() -> Int64! {
        return id
    }
    
    func ImageURL() -> NSURL! {
        return imageURL
    }
    
}
