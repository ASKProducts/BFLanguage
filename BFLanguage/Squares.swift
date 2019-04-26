//
//  Squares.swift
//  BFLanguage
//
//  Created by Aaron Kaufer on 4/25/19.
//  Copyright © 2019 Aaron Kaufer. All rights reserved.
//

import Foundation

extension BFProgram{
    
    func load_Squares(){
        start()
        
        let n = newRegister()
        input(into: n)
        n += 1
        let i = newRegister()
        
        _while({i != n}) {
            output({i*i})
            i += 1
        }
        
        end()
    }
    
}
