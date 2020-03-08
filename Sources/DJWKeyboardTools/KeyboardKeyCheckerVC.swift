//
//  KeyboardKeyCheckerVC.swift
//  Stage2
//
//  Created by dejaWorks on 01/06/2018.
//  Copyright © 2018 dejaWorks. All rights reserved.
//

import UIKit

class KeyboardKeyCheckerVC: BaseViewController {

    /// Event for key press
    var onStandardPress:((_ :Cmd)->Void)?
    
    /// Timer for seting firstResponder
    var timerForCheckingExternalKeyboardExistance           = Timer()

    
    /// Listen for Shorcut keys 1/3
    override var canBecomeFirstResponder: Bool { return true }
    
    /// Listen for Shorcut keys 2/3
    override var keyCommands: [UIKeyCommand]? {

        var commands = [UIKeyCommand]()
        
        for cmd in Cmd.all{
            let command = UIKeyCommand(input: cmd.input,    modifierFlags: cmd.modifier, action: #selector(self.shortCutKey(_ :)))
            commands.append(command)
        }
        
        return commands
//        return [
//            UIKeyCommand(input: UIKeyInputDownArrow,    modifierFlags: [], action: #selector(self.shortCutKey(_ :))),
//            UIKeyCommand(input: UIKeyInputUpArrow,      modifierFlags: [], action: #selector(self.shortCutKey(_ :))),
//            UIKeyCommand(input: UIKeyInputLeftArrow,    modifierFlags: [], action: #selector(self.shortCutKey(_ :))),
//            UIKeyCommand(input: UIKeyInputRightArrow,   modifierFlags: [], action: #selector(self.shortCutKey(_ :))),
//            UIKeyCommand(input: " ",                    modifierFlags: [], action: #selector(self.shortCutKey(_ :))),
//
//            UIKeyCommand(input: "\n",                    modifierFlags: [], action: #selector(self.shortCutKey(_ :))),
//        ]
    }
    
    
    /// Listen for Shorcut keys 3/3
    @objc func shortCutKey(_ sender: UIKeyCommand) {
        if let command = Cmd.findCommand(sender){
            print("\(self) shortCutKey input: \(command.desc)")
            onStandardPress?(command)
            
            
        }
//        if let input = sender.input {
//            let modifier = sender.modifierFlags
//            if let cmd = Cmd.all.first(where: { $0.input == input && $0.modifier == modifier  }){
//                print("shortCutKey input: \(cmd.desc)")
//            }
//        }
    }
    /**
                 UIKeyCommand(input: "1", modifierFlags: .command, action: #selector(self.shortCutKey(_ :)), discoverabilityTitle: "Types"),
                 UIKeyCommand(input: "2", modifierFlags: .command, action: #selector(self.shortCutKey(_ :)), discoverabilityTitle: "Protocols"),
                 UIKeyCommand(input: "3", modifierFlags: .command, action: #selector(self.shortCutKey(_ :)), discoverabilityTitle: "Functions"),
                 UIKeyCommand(input: "4", modifierFlags: .command, action: #selector(self.shortCutKey(_ :)), discoverabilityTitle: "Operators"),
                 UIKeyCommand(input: "g", modifierFlags: UIKeyModifierFlags.alphaShift , action: #selector(self.shortCutKey(_ :)), discoverabilityTitle: "G key"),
     
                 UIKeyCommand(input: "f", modifierFlags: [.command, .alternate], action: #selector(shortCutKey(_ :)), discoverabilityTitle: "Find…"),
     */
    
    

    /// Add responder and timer
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        becomeFirstResponder()
        print("becomeFirstResponder?: \(isFirstResponder)")
    }
    /// Remove timer
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        print("viewWillDisappear")
        timerForCheckingExternalKeyboardExistance.invalidate()
    }
    /// Check keyboard
    @objc func checkKeyboard(){
        becomeFirstResponder()
        print("isFirstResponder: \(isFirstResponder)")
        if isFirstResponder {
            timerForCheckingExternalKeyboardExistance.invalidate()
        }else{
            timerForCheckingExternalKeyboardExistance = Timer.scheduledTimer(timeInterval: 0.5 , target: self,
                                                        selector: #selector(self.checkKeyboard), userInfo: nil, repeats: true)
        }
    }
}
