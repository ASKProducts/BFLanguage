//
//  BFREPL.swift
//  BFLanguage
//
//  Created by Aaron Kaufer on 4/25/19.
//  Copyright © 2019 Aaron Kaufer. All rights reserved.
//

import Foundation

func runBFREPL(interpreter: BFInterpreter, numerical: Bool) {
    let inputHandler: BFInputHandler = {
        if(numerical){
            if stdinNumericalInputBuffer.isEmpty {
                print("Input: ", terminator: "")
            }
            return stdinNumericalInputHandler(interpreter: $0)
        }
        else{
            if stdinCharacterInputBuffer.isEmpty {
                print("Input: ", terminator: "")
            }
            return stdinCharacterInputHandler(interpreter: $0)
        }

    }
    
    let outputHandler = numerical ? stdoutNumericalOutputHandler : stdoutCharacterOutputHandler
    while true {
        print()
        interpreter.printMemory()
        print("Code: ", terminator: "")
        let code = readLine()!
        if ["quit", "q"].contains(code.lowercased()) { break }
        if ["clear", "c"].contains(code.lowercased()) { interpreter.refresh(); continue }
        
        if let err = interpreter.run(code: code, input: inputHandler, output: outputHandler) {
            print("Error at instruction \(err)")
            let instructions = Array(code).filter{interpreter.validChars.contains($0)}
            print(instructions.map{String($0)}.joined())
            print(String(repeating: " ", count: err), terminator: "")
            print("^")
        }
    }
    
}
