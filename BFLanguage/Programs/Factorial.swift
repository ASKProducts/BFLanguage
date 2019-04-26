//
//  Factorial.swift
//  BFLanguage
//
//  Created by Aaron Kaufer on 4/25/19.
//  Copyright © 2019 Aaron Kaufer. All rights reserved.
//

import Foundation

extension BFProgram{
    
    func load_Factorial(){
        start()
        
        let n = getInput()
        let m = newRegister("m")
        m &= n
        
        let result = newRegister("result")
        result &= 1
        
        iterateDown(register: m) {
            result *= m
        }
        
        output(result)
        
        end()
    }
    
}
