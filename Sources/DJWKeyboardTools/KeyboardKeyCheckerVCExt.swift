//
//  KeyboardKeyCheckerVCExt.swift
//  Stage2
//
//  Created by dejaWorks on 01/06/2018.
//  Copyright © 2018 dejaWorks. All rights reserved.
//

import UIKit

extension KeyboardKeyCheckerVC {
    enum Cmd:Int{
        case space, enter
        case left, right, up, down
        case control, altOption, command, shift
        
        
        var input:String{
            switch self {
            case .left: return UIKeyCommand.inputLeftArrow
            case .right: return UIKeyCommand.inputRightArrow
            case .up: return UIKeyCommand.inputUpArrow
            case .down: return UIKeyCommand.inputDownArrow
            case .command, .altOption, .control, .shift: return ""
            case .space:    return " "
            case .enter:    return "\r"
            
            }
        }
        var modifier:UIKeyModifierFlags{
            switch self {
            case .command:  return [.command]
            case .altOption:return [.alternate]
            case .control:  return [.control]
            case .shift:    return [.shift]
            default:return []
            }
        }
        var desc:String{
            switch self {
            case .left:         return "◀︎ left"
            case .right:        return "▶︎ right"
            case .up:           return "▲ up"
            case .down:         return "▼ down"
            case .altOption:    return "⌥ alt/option"
            case .command:      return " command"
            case .control:      return "^ control"
            case .space:        return "space"
            case .shift:        return "⇧ shift"
            case .enter:        return "↩︎ return"
            }
        }
        static var all:[Cmd]{
            var tmp = [Cmd]()
            var i = 0
            while true{
                if let cmd = Cmd(rawValue: i){
                    tmp.append(cmd)
                    i += 1
                }else{
                    return tmp
                }
            }
        }
        static func findCommand(_ sender: UIKeyCommand)->Cmd?{
            if let input = sender.input {
                let modifier = sender.modifierFlags
                if let cmd = Cmd.all.first(where: { $0.input == input && $0.modifier == modifier  }){
                    return cmd
                }
            }
            return nil
        }
    }
}
