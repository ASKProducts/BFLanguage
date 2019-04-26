//
//  BFRegister.swift
//  BFLanguage
//
//  Created by Aaron Kaufer on 4/25/19.
//  Copyright © 2019 Aaron Kaufer. All rights reserved.
//

import Foundation

class BFRegister{
    static func === (lhs: BFRegister, rhs: BFRegister) -> Bool {
        return lhs.location == rhs.location
    }
    static func !== (lhs: BFRegister, rhs: BFRegister) -> Bool {
        return !(lhs.location == rhs.location)
    }
    
    
    let location: Int
    let program: BFProgram
    
    var cleared: Bool = true
    var name: String
    
    init(location: Int, program: BFProgram, name: String = "") {
        self.location = location
        self.program = program
        self.name = name
    }
    
}

//arithmetic operators on registers (all of these are extremely code inefficient)
//WARNING: nearly all operations create a new register. ALWAYS use a scope around any of these operations.
extension BFRegister{
    
    static func +(a: BFRegister, b: BFRegister) -> BFRegister{
        let p = a.program
        let sum = p.newRegister("(\(a.name) + \(b.name))")
        p.computeSum(a: a, b: b, result: sum)
        return sum
    }
    static func +(a: BFRegister, b: Int) -> BFRegister {
        let p = a.program
        let sum = p.newRegister("(\(a.name) + \(b))")
        p.add(register: a, into: sum)
        p.increment(register: sum, by: b)
        return sum
    }
    
    static func -(a: BFRegister, b: BFRegister) -> BFRegister{
        let p = a.program
        let diff = p.newRegister("(\(a.name) - \(b.name))")
        p.computeDifference(a: a, b: b, result: diff)
        return diff
    }
    
    static func *(a: BFRegister, b: BFRegister) -> BFRegister{
        let p = a.program
        let product = p.newRegister("(\(a.name) * \(b.name))")
        p.computeProduct(a: a, b: b, result: product)
        return product
    }
    static func *(a: BFRegister, b: Int) -> BFRegister {
        let p = a.program
        let product = p.newRegister("(\(a.name) * \(b))")
        p.add(register: a, into: product)
        p.multiply(register: a, by: b)
        return product
    }
    
    static prefix func ! (reg: BFRegister) -> BFRegister {
        let p = reg.program
        let result = p.newRegister("!(\(reg.name))")
        p.computeLogicalNegation(of: reg, result: result)
        return result
    }
    
    
}

//logical operators
extension BFRegister{
    
    //creates a register whose value is nonzero iff lhs==rhs (just the negation of the difference)
    static func == (lhs: BFRegister, rhs: BFRegister) -> BFRegister {
        let reg = !(lhs - rhs)
        reg.name = "(\(lhs.name) == \(rhs.name))"
        return reg
    }
    static func == (lhs: BFRegister, rhs: Int) -> BFRegister {
        let reg = !(lhs + (-rhs))
        reg.name = "(\(lhs.name) == \(rhs))"
        return reg
    }
    
    static func != (lhs: BFRegister, rhs: BFRegister) -> BFRegister {
        let reg = (lhs - rhs)
        reg.name = "(\(lhs.name) != \(rhs.name))"
        return reg
    }
    static func != (lhs: BFRegister, rhs: Int) -> BFRegister {
        let reg = (lhs + (-rhs))
        reg.name = "(\(lhs.name) != \(rhs))"
        return reg
    }
    
    static func > (lhs: BFRegister, rhs: BFRegister) -> BFRegister {
        let p = lhs.program
        let result = p.newRegister("(\(lhs.name) > \(rhs.name))")
        p.ifGreater(a: lhs, b: rhs) {
            p.increment(register: result)
        }
        return result
    }
    
    static func >= (lhs: BFRegister, rhs: BFRegister) -> BFRegister {
        let p = lhs.program
        let result = p.newRegister("(\(lhs.name) >= \(rhs.name))")
        p.ifGreaterOrEqual(a: lhs, b: rhs) {
            p.increment(register: result)
        }
        return result
    }
    
    static func < (lhs: BFRegister, rhs: BFRegister) -> BFRegister {
        return (rhs > lhs)
    }
    
    static func <= (lhs: BFRegister, rhs: BFRegister) -> BFRegister {
        return (rhs >= lhs)
    }
}

//assignment operations
extension BFRegister {
    static func &= (lhs: BFRegister, rhs: ExpressionBlock){
        let p = lhs.program
        p.registerScope {
            p.copy(register: rhs(), into: lhs)
        }
    }
    static func &= (lhs: BFRegister, rhs: BFRegister){
        lhs.program.copy(register: rhs, into: lhs)
    }
    static func &= (lhs: BFRegister, rhs: Int){
        let p = lhs.program
        p.clear(register: lhs)
        p.increment(register: lhs, by: rhs)
    }
    
    static func += (lhs: BFRegister, rhs: Int){
        lhs.program.increment(register: lhs, by: rhs)
    }
    static func += (lhs: BFRegister, rhs: BFRegister){
        lhs.program.add(register: rhs, into: lhs)
    }
    static func += (lhs: BFRegister, rhs: ExpressionBlock){
        let p = lhs.program
        p.registerScope {
            p.add(register: rhs(), into: lhs)
        }
    }
    
    static func -= (lhs: BFRegister, rhs: Int){
        lhs.program.increment(register: lhs, by: -rhs)
    }
    static func -= (lhs: BFRegister, rhs: BFRegister){
        lhs.program.subtract(register: rhs, from: lhs)
    }
    static func -= (lhs: BFRegister, rhs: ExpressionBlock){
        let p = lhs.program
        p.registerScope {
            p.subtract(register: rhs(), from: lhs)
        }
    }
    
    static func *= (lhs: BFRegister, rhs: Int){
        lhs.program.multiply(register: lhs, by: rhs)
    }
    static func *= (lhs: BFRegister, rhs: BFRegister){
        lhs.program.multiply(register: lhs, by: rhs)
    }
    static func *= (lhs: BFRegister, rhs: ExpressionBlock){
        let p = lhs.program
        p.registerScope {
            p.multiply(register: lhs, by: rhs())
        }
    }
    
}
