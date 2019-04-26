//
//  BFIO.swift
//  BFLanguage
//
//  Created by Aaron Kaufer on 4/24/19.
//  Copyright © 2019 Aaron Kaufer. All rights reserved.
//

import Foundation

typealias BFInputHandler = ((BFInterpreter) -> (Int))
typealias BFOutputHandler = ((BFInterpreter, Int) -> ())

func readNonemptyLine() -> String {
    var line = ""
    while line == ""{
        guard let lineRead = readLine() else{
            fatalError("Failed to read from stdin")
        }
        line = lineRead
    }
    return line
}

var stdinNumericalInputBuffer: [Int] = []
let stdinNumericalInputHandler: BFInputHandler = {(interpreter: BFInterpreter) -> Int in
    if !stdinNumericalInputBuffer.isEmpty {
        return stdinNumericalInputBuffer.removeFirst()
    }
    let line = readNonemptyLine()
    let nums = line.split(separator: " ").map{Int($0)!}
    stdinNumericalInputBuffer.append(contentsOf: nums)
    return stdinNumericalInputBuffer.removeFirst()
}

var stdinCharacterInputBuffer: [Int] = []
let stdinCharacterInputHandler: BFInputHandler = {(interpreter: BFInterpreter) -> Int in
    if !stdinCharacterInputBuffer.isEmpty {
        return stdinCharacterInputBuffer.removeFirst()
    }
    let line = readNonemptyLine()
    let chars = line.map{ Int($0.asciiValue!) }
    stdinCharacterInputBuffer.append(contentsOf: chars)
    return stdinCharacterInputBuffer.removeFirst()
}

let stdoutNumericalOutputHandler: BFOutputHandler = {(interpreter: BFInterpreter, output: Int) in
    print(output, terminator: " ")
}

let stdoutCharacterOutputHandler: BFOutputHandler = {(interpreter: BFInterpreter, output: Int) in
    print(Character(UnicodeScalar(output)!), terminator: "")
}

