//
//  ViewController.swift
//  Calculator
//
//  Created by Abdullah Adwan on 2/10/17.
//  Copyright © 2017 Abdullah Adwan. All rights reserved.
//

import UIKit

class CalculatorViewController: UIViewController {
    
    
    //MARK: Properties
    
    @IBOutlet weak var variableLabel: UILabel!
    @IBOutlet weak var display: UILabel!
    @IBOutlet weak var calculationsDescription: UILabel!
    
    var userIsInMiddleOfTyping = false
    
    var displayValue : Double {
        get {
            return Double(display.text!)!
        }
        set {
            display.text = String(format: "%.8f", newValue)
        }
    }
    
    private var brain = Calculator()
    
    //MARK: Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.barStyle = UIBarStyle.blackTranslucent
        navigationController?.navigationBar.tintColor = UIColor.white
        adjustButtonLayout(for: view, isPortrait: traitCollection.horizontalSizeClass == .compact && traitCollection.verticalSizeClass == .regular)
    }
    
    override func willTransition(to newCollection: UITraitCollection, with coordinator: UIViewControllerTransitionCoordinator) {
        super.willTransition(to: newCollection, with: coordinator)
        adjustButtonLayout(for: view, isPortrait: newCollection.horizontalSizeClass == .compact && newCollection.verticalSizeClass == .regular)
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    private func adjustButtonLayout(for view: UIView, isPortrait: Bool) {
        for subview in view.subviews {
            if subview.tag == 1 {
                subview.isHidden = isPortrait
            } else if subview.tag == 2 {
                subview.isHidden = !isPortrait
            }
            if let button = subview as? UIButton {
                button.setTitleColor(UIColor.black, for: .highlighted)
            } else if let stack = subview as? UIStackView {
                adjustButtonLayout(for: stack, isPortrait: isPortrait);
            }
        }
    }
    
    func updateUI(accordingTo symbol: String? = nil) {
        
        let calculations = brain.evaluate(using: variables)
        
        if let result = calculations.result {
            displayValue = result
        }
        calculationsDescription.text! = calculations.description
        
        
        if let mathmeticalSymbol = symbol {
            if mathmeticalSymbol == "M" {
                return
            } else if mathmeticalSymbol == "="  || !calculations.isPending {
                calculationsDescription.text! += " ="
            } else if calculations.isPending &&  mathmeticalSymbol != "C"  {
                calculationsDescription.text! += " ..."
            }
        }
    }
    
    //MARK: Actions
    
    @IBAction func touchDigitOrDecimalPoint(_ sender: UIButton) {
        let digitOrDecimalPoint  = sender.currentTitle!
        if  userIsInMiddleOfTyping && display.text!.contains(".") && digitOrDecimalPoint == "." {
            ///
        } else if userIsInMiddleOfTyping {
            if let textCurrentlyInDisplay = display.text {
                display.text = textCurrentlyInDisplay + digitOrDecimalPoint
            }
        } else {
            if digitOrDecimalPoint == "." {
                display.text = "0" + digitOrDecimalPoint
            } else {
                display.text = digitOrDecimalPoint
            }
            userIsInMiddleOfTyping = true
        }
        
    }

    @IBAction func preformOperation(_ sender: UIButton) {
        
        if userIsInMiddleOfTyping {
            brain.setOperand(displayValue)
            userIsInMiddleOfTyping = false
        }
        
        if let mathmeticalSymbol = sender.currentTitle {
            brain.preformOperation(mathmeticalSymbol)
            updateUI(accordingTo: mathmeticalSymbol)
        }
    }
    
    @IBAction func setVariable(_ sender: UIButton) {
        brain.setOperand(variable: "M")
        updateUI()
    }
    
    @IBAction func evaluateVariable(_ sender: UIButton) {
        variables["M"] = displayValue
        variableLabel.text = "M=\(displayValue)"
        userIsInMiddleOfTyping = false
        display.text = "0"
        updateUI(accordingTo: "M")
    }
    
    @IBAction func undo(_ sender: UIButton) {
        if userIsInMiddleOfTyping && !display.text!.isEmpty {
            let lastCharIndex = display.text!.index(display.text!.endIndex, offsetBy: -1)
            display.text!.remove(at: lastCharIndex)
            if display.text!.isEmpty {
                display.text! = "0"
                userIsInMiddleOfTyping = false
            }
            
        } else {
            brain.undo()
            updateUI()
        }
        
    }
    
    @IBAction func clearDisplay(_ sender: UIButton) {
        brain = Calculator()
        variables = [:]
        display.text = "0"
        variableLabel.text = ""
        calculationsDescription.text = " "
        userIsInMiddleOfTyping = false
    }
}

