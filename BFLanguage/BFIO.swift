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
func stdinNumericalInputHandler(interpreter: BFInterpreter) -> Int{
    if !stdinNumericalInputBuffer.isEmpty {
        return stdinNumericalInputBuffer.removeFirst()
    }
    let line = readNonemptyLine()
    let nums = line.split(separator: " ").map{Int($0)!}
    stdinNumericalInputBuffer.append(contentsOf: nums)
    return stdinNumericalInputBuffer.removeFirst()
}

var stdinCharacterInputBuffer: [Int] = []
func stdinCharacterInputHandler(interpreter: BFInterpreter) -> Int {
    if !stdinCharacterInputBuffer.isEmpty {
        return stdinCharacterInputBuffer.removeFirst()
    }
    let line = readNonemptyLine()
    let chars = line.map{ Int($0.asciiValue!) }
    stdinCharacterInputBuffer.append(contentsOf: chars)
    return stdinCharacterInputBuffer.removeFirst()
}

func stdoutNumericalOutputHandler(interpreter: BFInterpreter, output: Int){
    print(output, terminator: "")
}

func stdoutCharacterOutputHandler(interpreter: BFInterpreter, output: Int){
    print(Character(UnicodeScalar(output)!), terminator: "")
}

