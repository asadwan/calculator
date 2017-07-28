//
//  Calculator.swift
//  Calculator
//
//  Created by Abdullah Adwan on 2/23/17.
//  Copyright © 2017 Abdullah Adwan. All rights reserved.
//

import Foundation

var variables = [String:Double]()

struct Calculator {
    
    // MARK: Properties
    
    @available(iOS, deprecated)
    var description: String {
        return evaluate().description
    }
    
    @available(iOS, deprecated)
    var resultIsPending : Bool {
        return evaluate().isPending
    }
    
    @available(iOS, deprecated)
    var result : Double? {
        get {
            return evaluate().result
        }
    }
    
    private var stack = [Element]()
    
    private enum Element {
        case variableOperand(String)
        case constantOperand(Double)
        case operation(String)
    }
    
    private enum Operation {
        case constant(Double)
        case unaryOperation((Double) -> Double, (String) -> String)
        case binaryOperation((Double, Double) -> Double, (String, String) -> String)
        case equals
        case clear
    }
    
    private var operations = [
        "π" : Operation.constant(Double.pi),
        "e" : Operation.constant(M_E),
        
        "√" : Operation.unaryOperation(sqrt, {"√(" + $0 + ")"}),
        "sin": Operation.unaryOperation(sin, {"sin(" + $0 + ")"}),
        "cos": Operation.unaryOperation(cos, {"cos(" + $0 + ")"}),
        "tan": Operation.unaryOperation(tan, {"tan(" + $0 + ")"}),
        "ln": Operation.unaryOperation(log2, {"ln(" + $0 + ")"}),
        "%": Operation.unaryOperation({$0/100}, {"%(" + $0 + ")"}),
        "±": Operation.unaryOperation({-($0)}, {"±(" + $0 + ")"}),
        "x²":Operation.unaryOperation({$0 * $0}, {"x²(" + $0 + ")"} ),
        
        "+" : Operation.binaryOperation({$0 + $1}, {$0 + " + " + $1}),
        "×" : Operation.binaryOperation({$0 * $1}, {$0 + " × " + $1}),
        "-" : Operation.binaryOperation({$0 - $1}, {$0 + " - " + $1}),
        "÷" : Operation.binaryOperation({$0 / $1}, {$0 + " ÷ " + $1}),
        "C" : Operation.clear,
        "=" : Operation.equals
    ]
    
    //MARK: Methods
    
    mutating func undo() {
        if !stack.isEmpty {
            let element = stack.removeLast()
            var operation: String!
            switch element {
            case .operation(let symbol):
                operation = symbol
            default:
                break
            }
            if  operation == "=" && !stack.isEmpty {
                stack.removeLast()
            }
        }
    }
    
    func evaluate(using variables: Dictionary<String,Double>? = nil) -> (result: Double?, isPending: Bool, description: String ) {

        var pendingBianryOperation: PendingBinaryOperation?
        struct PendingBinaryOperation {
            let function :(Double,Double) -> Double
            let description : (String, String) -> String
            let firstOperand: (Double, String)
            
            func perform(with secondOperand: (Double, String)) -> (Double, String) {
                return (function(firstOperand.0, secondOperand.0), description(firstOperand.1, secondOperand.1))
            }
        }
        
        var isPending: Bool {
            return pendingBianryOperation != nil
        }
        var accumulator : (Double, String)?
        var result: Double? {
            if accumulator != nil {
                return accumulator!.0
            }
            return nil
        }
        var description: String {
            if isPending {
                return pendingBianryOperation!.description(pendingBianryOperation!.firstOperand.1, accumulator?.1 ?? "")
            }
            return accumulator?.1 ?? ""
        }
        
        func performPendingBinaryOperation() {
            if isPending && accumulator != nil {
                accumulator = pendingBianryOperation!.perform(with: accumulator!)
                pendingBianryOperation = nil
            }
        }
        
        for element in stack {
            switch element {
            case .constantOperand(let value):
                accumulator = (value, "\(value)")
                
            case .operation(let symbol):
                if let operation = operations[symbol] {
                    
                    switch operation {
                    case .constant(let value):
                        accumulator = (value, symbol)
                        
                    case .unaryOperation(let function, let description):
                        if accumulator != nil {
                            accumulator = (function(accumulator!.0), description(accumulator!.1))
                        }
                        
                    case .binaryOperation(let function, let description):
                        performPendingBinaryOperation()
                        if accumulator != nil {
                            pendingBianryOperation = PendingBinaryOperation(function: function, description: description, firstOperand: accumulator!)
                            accumulator = nil
                        }
                        
                    case .equals:
                        if accumulator != nil {
                        performPendingBinaryOperation()
                        pendingBianryOperation = nil
                        }
                        
                    case .clear:
                        accumulator = nil
                        pendingBianryOperation = nil
                    }
                }
                
            case .variableOperand(let name):
                if let value = variables?[name] {
                    accumulator = (value, name)
                } else {
                    accumulator = (0, name)
                }
            }
        }
        
     
        print(accumulator ?? "")
        return (result, isPending, description)
    }
    
    mutating func preformOperation(_ symbol: String) {
        stack.append(Element.operation(symbol))
    }
    
    mutating func setOperand(_ operand: Double) {
        stack.append(Element.constantOperand(operand))
    }
    
    mutating func setOperand(variable named: String) {
        stack.append(Element.variableOperand(named))
    }
    
    
}
