//
//  File.swift
//  SourceView
//
//  Created by Pan Qingrong on 21/11/2017.
//  Copyright © 2017 Big Nerd Ranch. All rights reserved.
//

import Foundation

class Dog{
    init(){
        
    }
    init(p:Bool){
        
    }
    init(s:Int){
        
    }
    
}

class NoisyDog:Dog{
    init(c:String){
        super.init()
    }
    init(c:Character){
        super.init()
    }
    
}

let a = Dog()
let c = Dog(p: true)

let b = NoisyDog(c:"")


