//
//  File.swift
//  SourceView
//
//  Created by Pan Qingrong on 21/11/2017.
//  Copyright © 2017 Big Nerd Ranch. All rights reserved.
//

import Foundation

class ChildNode:BaseNode{
    required init() {
        super.init()
        self.nodeTitle = ""
    }
    
    convenience init(isLeaf aIsLeaf:Bool?){
        self.init()
        if let isLeaf = aIsLeaf{
            if isLeaf {
                self.isLeaf = true
            }
        }
    }
    override var description: String{
        return "ChildNode"
    }
    override var mutableKeys: NSArray?{
        if let keys = super.mutableKeys{
            keys.addingObjects(from: ["description"])
        }
        return super.mutableKeys
    }
}
