//
//  BFProgram.swift
//  BFLanguage
//
//  Created by Aaron Kaufer on 4/25/19.
//  Copyright © 2019 Aaron Kaufer. All rights reserved.
//

import Foundation



typealias CodeBlock = (()->())
typealias ExpressionBlock = (()->(BFRegister))



//basic operations
class BFProgram{
    
    var code = ""
    let numRegisters: Int
    var registerFreeList: [Bool] = []
    var location: Int = 0
    
    var registerScopes: [[BFRegister]] = [[]] //registerScopes[0] is the global scope
    
    var registerLog: String = ""
    
    var indentLevel = 0
    
    let includeComments: Bool
    
    init(numRegisters: Int = 10, includeComments: Bool = true) {
        self.numRegisters = numRegisters
        registerFreeList = [Bool](repeating: true, count: numRegisters)
        self.includeComments = includeComments
    }
    
    func start(){
        code = ""
        location = 0
        registerScopes = [[]]
        registerLog = ""
    }
    func end(){ }
    
    func increment(by: Int = 1){
        if by > 0 { code += String(repeating: "+", count: by) }
        else { code += String(repeating: "-", count: -by) }
    }
    func decrement(by: Int = 1){
        increment(by: -by)
    }
    
    func rightShift(by: Int = 1){
        if by > 0 { code += String(repeating: ">", count: by) }
        else {code += String(repeating: "<", count: -by)}
        location += by
    }
    
    func leftShift(by: Int = 1){
        rightShift(by: -by)
    }
    
    func shift(to newLocation: Int){
        rightShift(by: newLocation - location)
    }
    
    func loop(contents: CodeBlock) {
        code += "["
        contents()
        code += "]"
    }
    
    func clear(){
        loop { decrement() }
    }
    
    func input(){ code += "," }
    func output(){ code += "." }
    
    func displayMemory(){ code += "M" }
    
    func addComment(_ comment: String){
        guard includeComments else { return }
        code += comment.map{ BFInterpreter.validChars.contains($0) ? "_" : $0 }
    }
    func addLineBreak(){
        addComment("\n" + String(repeating: "    ", count: indentLevel) )
    }
    
}

//basic register operations
extension BFProgram {
    
    func firstFreeRegisterLocation() -> Int {
        for i in 0..<numRegisters{
            if registerFreeList[i] { return i }
        }
        fatalError("Out of free registers")
    }
    func newRegister(_ name: String = "", _ initialValue: Int = 0) -> BFRegister {
        let loc = firstFreeRegisterLocation()
        registerFreeList[loc] = false
        let reg = BFRegister(location: loc, program: self, name: name)
        registerScopes[registerScopes.count - 1].append(reg)
        
        if initialValue != 0{
            increment(register: reg, by: initialValue)
        }
        
        registerLog += "Created \(reg.name) in \(reg.location), scope \(registerScopes.count - 1)\n"
        return reg
    }
    

    func free(register: BFRegister){
        if !register.cleared { clear(register: register) }
        guard !registerFreeList[register.location] else{
            fatalError("Freeing an already free register")
        }
        registerFreeList[register.location] = true
        for i in 0..<registerScopes.count{
            if let ind = registerScopes[i].firstIndex(where: { $0 === register }){
                registerScopes[i].remove(at: ind)
                registerLog += "Freed \(register.name) in \(register.location), scope \(i)\n"
            }
        }
    }
    
    func openRegisterScope(){
        registerScopes.append([])
    }
    func closeRegisterScope(){
        guard registerScopes.count > 1 else{
            fatalError("Attempted to close global scope.")
        }
        let regs = registerScopes.last!
        for reg in regs{
            free(register: reg)
        }
        registerScopes.removeLast()
    }
    func registerScope(contents: CodeBlock){
        openRegisterScope()
        contents()
        closeRegisterScope()
    }
    
    func shift(to reg: BFRegister){
        guard !registerFreeList[reg.location] else{
            fatalError("Attempted to shift to a free register")
        }
        shift(to: reg.location)
    }
    
    func increment(register: BFRegister, by: Int = 1){
        guard !registerFreeList[register.location] else{
            fatalError("Attempted to increment to a free register")
        }
        shift(to: register)
        increment(by: by)
        register.cleared = false
    }
    func decrement(register: BFRegister, by: Int = 1){
        guard !registerFreeList[register.location] else{
            fatalError("Attempted to decrement to a free register")
        }
        shift(to: register)
        decrement(by: by)
        register.cleared = false
    }
    func clear(register: BFRegister){
        guard !registerFreeList[register.location] else{
            fatalError("Attempted to clear to a free register")
        }
        if register.cleared { return }
        shift(to: register)
        clear()
        register.cleared = true
    }
    
    func input(into reg:BFRegister){
        guard !registerFreeList[reg.location] else{
            fatalError("Attempted to input into a free register")
        }
        shift(to: reg)
        reg.cleared = false
        input()
    }
    
    //creates a new register
    func getInput() -> BFRegister{
        let reg = newRegister("input()")
        input(into: reg)
        return reg
    }
    
    func output(_ reg: BFRegister){
        guard !registerFreeList[reg.location] else{
            fatalError("Attempted to out to a free register")
        }
        shift(to: reg)
        output()
    }
    func output(_ expr: ExpressionBlock){
        registerScope {
            let resultReg = expr()
            output(resultReg)
        }
    }
    
    func output(_ num: Int){
        let tmp = newRegister("(temp output(\(num)))")
        increment(register: tmp, by: num)
        output(tmp)
        free(register: tmp)
    }
    
}

//control flow
extension BFProgram{
    func whileNonzero(register: BFRegister, contents: CodeBlock){
        shift(to: register)
        loop {
            registerScope {
                contents()
            }
            shift(to: register)
        }
        register.cleared = true
    }
    
    func iterateDown(register: BFRegister, contents: CodeBlock){
        whileNonzero(register: register) {
            contents()
            decrement(register: register)
        }
    }
    
    func destructiveIfNonzero(register: BFRegister, contents: CodeBlock){
        whileNonzero(register: register) {
            contents()
            clear(register: register)
        }
    }
    
    func ifNonzero(register: BFRegister, contents: CodeBlock){
        let tmp = newRegister("(tmp ifNonzero(\(register.name)))")
        copy(register: register, into: tmp)
        destructiveIfNonzero(register: tmp) {
            contents()
        }
        free(register: tmp)
    }
    
    func destructiveIfZero(register: BFRegister, contents: CodeBlock){
        let tmp = newRegister("(tmp destructiveIfZero(\(register.name)))")
        increment(register: tmp)
        destructiveIfNonzero(register: register) {
            decrement(register: tmp)
        }
        destructiveIfNonzero(register: tmp) {
            contents()
        }
        free(register: tmp)
    }
    
    func ifZero(register: BFRegister, contents: CodeBlock){
        let tmp = newRegister("(tmp ifZero(\(register.name)))")
        copy(register: register, into: tmp)
        destructiveIfZero(register: tmp) {
            contents()
        }
        free(register: tmp)
    }
    
    func destructiveIfEqual(a: BFRegister, b: BFRegister, contents: CodeBlock){
        transfer(register: a, into: b, times: -1) //a=0, b=b-a
        destructiveIfZero(register: b) {
            contents()
        }
    }
    func ifEqual(a: BFRegister, b: BFRegister, contents: CodeBlock){
        let tmp = newRegister("(tmp ifEqual(\(a.name), \(b.name)))")
        computeDifference(a: a, b: b, result: tmp)
        destructiveIfZero(register: tmp) {
            contents()
        }
        free(register: tmp)
    }
    
    func logicallyNegate(register: BFRegister) {
        let tmp = newRegister("(tmp logicallyNegate(\(register.name)))")
        destructiveIfZero(register: register) {
            increment(register: tmp)
        }
        copy(register: tmp, into: register)
        free(register: tmp)
    }
    
    func computeLogicalNegation(of register: BFRegister, result: BFRegister) {
        copy(register: register, into: result)
        logicallyNegate(register: result)
    }
    
    //a will always end at 0
    //if a>b, then b ends with 0
    //if b>a, then b ends with b-a
    func destructiveIfGreater(a: BFRegister, b: BFRegister, contents: CodeBlock){
        iterateDown(register: a) {
            ifZero(register: b){
                contents()
                clear(register: a)
                increment(register: a)
                increment(register: b)
            }
            decrement(register: b)
        }
    }
    
    func ifGreater(a: BFRegister, b: BFRegister, contents: CodeBlock){
        let tmpa = newRegister("(tmpa ifGreater(\(a.name), \(b.name)))")
        copy(register: a, into: tmpa)
        let tmpb = newRegister("(tmpb ifGreater(\(a.name), \(b.name)))")
        copy(register: b, into: tmpb)
        destructiveIfGreater(a: tmpa, b: tmpb) {
            contents()
        }
        free(register: tmpa)
        free(register: tmpb)
    }
    
    
    func destructiveIfGreaterOrEqual(a: BFRegister, b: BFRegister, contents: CodeBlock){
        increment(register: a)
        destructiveIfGreater(a: a, b: b, contents: contents)
    }
    
    func ifGreaterOrEqual(a: BFRegister, b: BFRegister, contents: CodeBlock){
        let tmpa = newRegister("(tmpa ifGreaterOrEqual(\(a.name), \(b.name)))")
        copy(register: a, into: tmpa)
        let tmpb = newRegister("(tmpb ifGreaterOrEqual(\(a.name), \(b.name)))")
        copy(register: b, into: tmpb)
        destructiveIfGreaterOrEqual(a: tmpa, b: tmpb) {
            contents()
        }
        free(register: tmpa)
        free(register: tmpb)
    }
    
    func _if(_ condition: ExpressionBlock, contents: CodeBlock){
        registerScope {
            let condReg = condition()
            
            addLineBreak()
            addComment("if(\(condReg.name)):")
            indentLevel += 1
            addLineBreak()
            
            ifNonzero(register: condReg, contents: {
                contents()
            })
            
            indentLevel -= 1
            addLineBreak()
        }
    }
    
    func _while(_ condition: ExpressionBlock, contents: CodeBlock){
        let c = condition()
        let condReg = newRegister(c.name)
        condReg &= {c}
        
        whileNonzero(register: condReg, contents: {
            addLineBreak()
            addComment("while(\(condReg.name)):")
            indentLevel += 1
            addLineBreak()
            
            contents()
            
            addLineBreak()
            addComment("recheck(\(condReg.name)):")
            addLineBreak()
            condReg &= {condition()}
            
            indentLevel -= 1
            addLineBreak()
        })
        
        free(register: condReg)
    }
}

//register artihmetic
extension BFProgram{
    
    func distribute(register: BFRegister, into others: [(BFRegister, Int)]) {
        iterateDown(register: register) {
            for (reg, times) in others{
                increment(register: reg, by: times)
            }
        }
    }
    
    func transfer(register: BFRegister, into others: [BFRegister], times: Int = 1){
        distribute(register: register, into: others.map{ ($0, times) })
    }
    
    func transfer(register: BFRegister, into other: BFRegister, times: Int = 1){
        transfer(register: register, into: [other], times: times)
    }
    
    //add and subtract are non-destructive
    //rgister = register, other = other + register
    func add(register: BFRegister, into other: BFRegister, times: Int = 1){
        let tmp = newRegister("(tmp add(\(register.name), \(other.name)))")
        distribute(register: register, into: [(other, times), (tmp, 1)])
        transfer(register: tmp, into: register)
        free(register: tmp)
    }
    //register = register, other = other - register
    func subtract(register: BFRegister, from other: BFRegister, times: Int = 1){
        let tmp = newRegister("(tmp subtract(\(register.name), \(other.name)))")
        distribute(register: register, into: [(other, -1*times), (tmp, 1)])
        transfer(register: tmp, into: register)
        free(register: tmp)
    }
    
    func copy(register: BFRegister, into other: BFRegister){
        clear(register: other)
        add(register: register, into: other)
    }

    func computeSum(a: BFRegister, b: BFRegister, result: BFRegister){
        guard result !== a && result !== b else{
            fatalError("computeSum called with result equal to one of the arguments")
        }
        clear(register: result)
        add(register: a, into: result)
        add(register: b, into: result)
    }
    
    func computeDifference(a: BFRegister, b: BFRegister, result: BFRegister){
        guard result !== a && result !== b else{
            fatalError("computeSum called with result equal to one of the arguments")
        }
        clear(register: result)
        add(register: a, into: result)
        subtract(register: b, from: result)
    }
    
    //register = register*by
    func multiply(register: BFRegister, by: Int){
        let tmp = newRegister("(tmp muliply(\(register.name), \(by)))")
        add(register: register, into: tmp, times: by)
        transfer(register: tmp, into: register)
        free(register: tmp)
    }
    //a=a*b, b=b
    func multiply(register a: BFRegister, by b: BFRegister){
        let tmpa = newRegister("(tmpa muliply(\(a.name), \(b.name)))")
        let result = newRegister("(result muliply(\(a.name), \(b.name)))")
        copy(register: a, into: tmpa)
        iterateDown(register: tmpa) {
            add(register: b, into: result)
        }
        free(register: tmpa)
        clear(register: a)
        transfer(register: result, into: a)
        free(register: result)
    }
    
    func computeProduct(a: BFRegister, b: BFRegister, result: BFRegister){
        clear(register: result)
        add(register: a, into: result)
        multiply(register: result, by: b)
    }
    
    
    func divide(register a: BFRegister, by b: BFRegister){
        let tmpa = newRegister("(tmpa divide(\(a.name), \(b.name)))")
        copy(register: a, into: tmpa)
        clear(register: a)
        whileNonzero(register: tmpa) {
            
        }
        free(register: tmpa)
    }
    
    
}

