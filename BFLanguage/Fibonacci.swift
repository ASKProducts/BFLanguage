//
//  Fibonacci.swift
//  BFLanguage
//
//  Created by Aaron Kaufer on 4/25/19.
//  Copyright © 2019 Aaron Kaufer. All rights reserved.
//

import Foundation

extension BFProgram{
    
    func load_Fibonacci(){
        start()
        
        let a = newRegister()
        let b = newRegister()
        b += 1
        
        let n = newRegister()
        input(into: n)
        
        iterateDown(register: n) {
            output(b)
            
            let tmpb = newRegister()
            tmpb &= b
            b &= {a + b}
            a &= tmpb
        }
        
        end()
    }
}
