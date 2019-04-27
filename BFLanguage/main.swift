//
//  main.swift
//  BFLanguage
//
//  Created by Aaron Kaufer on 4/24/19.
//  Copyright © 2019 Aaron Kaufer. All rights reserved.
//

//+-<>,.[]

// , > , [ - < + >  ] < .

import Foundation

enum Mode{
    case REPL, Program
}

let mode: Mode = .Program

switch mode{
case .REPL:
    let interpreter = BFInterpreter(memoryLength: 100,
                                    maxValue: 256,
                                    maxInstructions: nil)
    
    
    runBFREPL(interpreter: interpreter,
              numerical: true,
              autoDisplayMemory: true)
    
case .Program:
    let p = BFProgram(includeComments: false)
    //p.start()
    
    p.load_Primes()
    
    //p.end()
    
    print(p.code)
    //print(p.registerLog)
    
    //TODO: if/else, for loop
    
    let interpreter = BFInterpreter(maxInstructions: nil)
    _ = interpreter.run(code: p.code,
                        input: stdinNumericalInputHandler,
                        output: stdoutNumericalOutputHandler)
    
}

