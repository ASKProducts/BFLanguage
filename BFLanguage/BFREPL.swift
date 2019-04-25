//
//  BFREPL.swift
//  BFLanguage
//
//  Created by Aaron Kaufer on 4/25/19.
//  Copyright © 2019 Aaron Kaufer. All rights reserved.
//

import Foundation

/* Commands to the REPL:
 q/quit: exits the REPL
 c/clear: refreshes the interepreter (clears memory, resets pointer)
 s/start: start recording multiple lines of code
 e/end: finishes recording multiple lines of code and immediately executes recorded lines
 
 Anything other than the verbatim case-insensitive versions of the above commands
 will be treated as raw brainfuck code to be fed to the interpreter.
 */

func runBFREPL(interpreter: BFInterpreter,
               numerical: Bool = true,
               autoDisplayMemory: Bool = true) {
    
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
    
    var didOutput = false
    let outputHandler: BFOutputHandler = {
        didOutput = true
        if(numerical) { return stdoutNumericalOutputHandler(interpreter: $0, output: $1) }
        else { return stdoutCharacterOutputHandler(interpreter: $0, output: $1) }
    }
    
    while true {
        
        if(didOutput){
            print()
            didOutput = false
        }
        if(autoDisplayMemory) { interpreter.printMemory() }
        
        print("Code: ", terminator: "")
        var code = readLine()!
        
        if ["quit", "q"].contains(code.lowercased()) { break }
        if ["clear", "c"].contains(code.lowercased()) {
            interpreter.refresh();
            continue
        }
        
        if ["start", "s"].contains(code.lowercased()){
            code = ""
            var line = readLine()!
            while !["end", "e"].contains(line){
                code += line
                line = readLine()!
            }
        }
        
        if let err = interpreter.run(code: code, input: inputHandler, output: outputHandler) {
            print("Error at instruction \(err)")
            interpreter.printInstruction(code: code, index: err)
        }
    }
    
}
