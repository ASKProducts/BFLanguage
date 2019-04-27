//
//  IsPrime.swift
//  BFLanguage
//
//  Created by Aaron Kaufer on 4/26/19.
//  Copyright © 2019 Aaron Kaufer. All rights reserved.
//

import Foundation

extension BFProgram{
    
    func load_Primes(){
        start()
        
        func isPrime(num: BFRegister) -> BFRegister {
            let output = newRegister("isPrime(\(num.name))", 1)
            registerScope {
                let i = newRegister("(i isPrime)", 2)
                _while({i < num}) {
                    _if({num % i == 0}){
                        output &= 0
                        i &= num
                    }
                    i += 1
                }
            }
            return output
        }
        
        let numPrimes = getInput("numPrimes")
        let i = newRegister("i", 2)
        whileNonzero(register: numPrimes){ //alternatively, _while({num != 0})
            _if({isPrime(num: i)}){
                output(i)
                numPrimes -= 1
            }
            i += 1
        }
        
        end()
    }
}
