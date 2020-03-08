//
//  KeyboardKeyCheckerVC.swift
//  Stage2
//
//  Created by dejaWorks on 01/06/2018.
//  Copyright © 2018 dejaWorks. All rights reserved.
//

import UIKit
import DJWBaseVC
open class KeyboardKeyCheckerVC:BaseVC {

    /// Event for key press
    open var onStandardPress:((_ :Cmd)->Void)?
    
    /// Timer for seting firstResponder
    var timerForCheckingExternalKeyboardExistance = Timer()

    
    /// Listen for Shorcut keys 1/3
    override public var canBecomeFirstResponder: Bool { return true }
    
    /// Listen for Shorcut keys 2/3
    override public var keyCommands: [UIKeyCommand]? {

        var commands = [UIKeyCommand]()
        
        for cmd in Cmd.all{
            let command = UIKeyCommand(input: cmd.input,    modifierFlags: cmd.modifier, action: #selector(self.shortCutKey(_ :)))
            commands.append(command)
        }
        
        return commands
    }
    
    
    /// Listen for Shorcut keys 3/3
    @objc func shortCutKey(_ sender: UIKeyCommand) {
        if let command = Cmd.findCommand(sender){
            print("\(self) shortCutKey input: \(command.desc)")
            onStandardPress?(command)
        }
    }

    open override func loadView() {
        super.loadView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.isHidden = true
    }
    

    /// Add responder and timer
    override open func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        becomeFirstResponder()
        print("becomeFirstResponder?: \(isFirstResponder)")
    }
    /// Remove timer
    override open func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        print("viewWillDisappear")
        timerForCheckingExternalKeyboardExistance.invalidate()
    }
    /// Check keyboard
    @objc public func checkKeyboard(){
        becomeFirstResponder()
        print("KeyboardKeyChecker->checkKeyboard() isFirstResponder: \(isFirstResponder)")
        if isFirstResponder {
            timerForCheckingExternalKeyboardExistance.invalidate()
        }else{
            timerForCheckingExternalKeyboardExistance = Timer.scheduledTimer(timeInterval: 0.5 , target: self,
                                                        selector: #selector(self.checkKeyboard), userInfo: nil, repeats: true)
        }
    }
}
