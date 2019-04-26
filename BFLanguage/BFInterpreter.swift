//
//  BFInterpreter.swift
//  BFLanguage
//
//  Created by Aaron Kaufer on 4/24/19.
//  Copyright © 2019 Aaron Kaufer. All rights reserved.
//

import Foundation




class BFInterpreter{
    
    let memoryLength: Int //number of cells of memory
    let maxValue: Int //cells contain integer values in the range [0, maxValue)
    
    var memory: [Int] = []
    var location: Int = 0 //location of the cursor
    
    var highestCellTouched: Int = 0
    
    static let validChars = Array("+-><.,[]MB") //M prints the memory, B prints the memory and the location in code
    
    let maxInstructions: Int? //maximum number of instructions to be performed before quitting, or nil if no maximum
    
    init(memoryLength: Int = 300, maxValue: Int = 256, maxInstructions: Int? = 1_000_000) {
        self.memoryLength = memoryLength
        self.maxValue = maxValue
        self.maxInstructions = maxInstructions
        
        refresh()
    }
    
    func refresh(){
        memory = [Int](repeating: 0, count: memoryLength)
        location = 0
        highestCellTouched = 0
    }
    
    //returns the index of an error, or nil if there was none
    func run(code: String, input: BFInputHandler, output: BFOutputHandler) -> Int?{
        var i: Int = 0
        let instructions = Array(code).filter{BFInterpreter.validChars.contains($0)}
        
        var matchingBraces: [Int] = [Int](repeating: 0, count: instructions.count)
        var openIndicies: [Int] = []
        for (i, instruction) in instructions.enumerated(){
            if instruction == "[" { openIndicies.append(i) }
            else if instruction == "]" {
                guard !openIndicies.isEmpty else { return i }
                let matchingOpen = openIndicies.removeLast()
                matchingBraces[i] = matchingOpen
                matchingBraces[matchingOpen] = i
            }
        }
        guard openIndicies.isEmpty else { return openIndicies.first }
        
        var instructionsPerformed = 0
        while i < instructions.count{
            switch instructions[i]{
            case "+":
                memory[location] += 1
                if memory[location] == maxValue { memory[location] = 0 }
            case "-":
                memory[location] -= 1
                if memory[location] == -1 { memory[location] = maxValue - 1 }
            case ">":
                if location == memoryLength - 1 { return i }
                location += 1
                if location > highestCellTouched { highestCellTouched = location }
            case "<":
                if location == 0 { return i }
                location -= 1
            case ".":
                output(self, memory[location])
            case ",":
                let num = input(self)
                if num >= 0 { memory[location] = num % maxValue }
                else{ memory[location] = maxValue - ( (-num) % maxValue ) }
            case "[":
                if memory[location] == 0 { i = matchingBraces[i] }
            case "]":
                if memory[location] != 0 { i = matchingBraces[i] }
            case "M":
                printMemory()
            case "B":
                print("Stopped at instruction \(instructionsPerformed), index \(i):")
                printInstruction(code: code, index: i)
                printMemory()
            default:
                break
            }
            
            i += 1
            instructionsPerformed += 1
            if maxInstructions != nil && instructionsPerformed == maxInstructions! { break }
        }
        
        return nil
    }
    
    func numToString(num: Int, minWidth: Int) -> String{
        let str = String(num)
        guard str.count <= minWidth else { return str }
        let buffer = String(repeating: " ", count: minWidth - str.count)
        return buffer + str
    }
    
    //print length amount of cells, or highestCellTouched+1 if nil, and ensure that at least minCells cells are printed
    func printMemory(length: Int? = nil, minCells: Int = 5, message: String? = "Memory:") {
        let cellWidth = String(maxValue).count
        var numCells = length ?? highestCellTouched + 1
        if numCells < minCells { numCells = minCells }
        
        if let message = message { print(message) }
        
        print(" ", terminator: "")
        for i in 0..<numCells{
            print(numToString(num: i, minWidth: cellWidth), terminator: " ")
        }
        print()
        
        print("+", terminator:"")
        for _ in 0..<numCells{
            print(String(repeating: "-", count: cellWidth), terminator: "+")
        }
        print()
        
        print("|", terminator: "")
        for i in 0..<numCells {
            print(numToString(num: memory[i], minWidth: cellWidth), terminator: "|")
        }
        print()
        
        print("+", terminator:"")
        for _ in 0..<numCells{
            print(String(repeating: "-", count: cellWidth), terminator: "+")
        }
        print()
        
        print(" ", terminator: "")
        for i in 0..<numCells {
            print(String(repeating: " ", count: cellWidth/2), terminator: "")
            print(location == i ? "^" : " ", terminator: "")
            print(String(repeating: " ", count: cellWidth % 2 == 0 ? cellWidth/2 - 1 : cellWidth/2), terminator: " ")
        }
        print()
    }
    

    func printInstruction(code: String, index: Int){
        let instructions = Array(code).filter{BFInterpreter.validChars.contains($0)}
        print(instructions.map{String($0)}.joined())
        print(String(repeating: " ", count: index), terminator: "")
        print("^")
    }
    
}
