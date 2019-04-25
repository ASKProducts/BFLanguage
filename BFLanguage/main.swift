//
//  main.swift
//  BFLanguage
//
//  Created by Aaron Kaufer on 4/24/19.
//  Copyright © 2019 Aaron Kaufer. All rights reserved.
//

import Foundation

let interpreter = BFInterpreter(memoryLength: 100,
                                maxValue: 256,
                                maxInstructions: 1_000_000)

runBFREPL(interpreter: interpreter,
          numerical: true,
          autoDisplayMemory: true)
