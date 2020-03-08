//
//  KeyboardSizeManager.swift
//  Stage2
//
//  Created by dejaWorks on 10/07/2019.
//  Copyright © 2019 dejaWorks. All rights reserved.
//

import UIKit


// MARK: - Keyboard Size Manager
protocol KeyboardSizeManagerDelegate:class {
    
    
    func setupKeyboardSizer()
    func registerForKeyboardNotifications()
    func deregisterFromKeyboardNotifications()
    func keyboarDidShown(notification: NSNotification)
    func keyboardDidHide(notification: NSNotification)
}
class KeyboardSizeManager:NSObject {
    
    public weak var delegate:KeyboardSizeManagerDelegate?
    
    public var isHardwareKeyboardPresent:Bool = false
    public var keyboardSize:CGSize?
    
    
    public var holderWindow:UIWindow?
    public var holderView:UIView?
    public var scrollV:UIScrollView?
    
    public var textView:UITextView?
    public var textLabel:UILabel?
    public var aView:UIView?
    
    /// Padding when textLabel is used, bottom pading.
    public var labelBottomPadding:CGFloat = 48.0
    
    func registerForKeyboardNotifications(){
        //Adding notifies on keyboard show
        NotificationCenter.default.addObserver(self, selector: #selector(keyboarDidShown(notification:)), name: UIResponder.keyboardDidShowNotification, object: nil)
        
        //Adding notifies on keyboard hide
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardDidHide(notification:)), name: UIResponder.keyboardDidHideNotification, object: nil)
    }
    
    func deregisterFromKeyboardNotifications(){
        //Removing notifies on keyboard appearing
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardDidShowNotification, object: nil)
        
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardDidHideNotification, object: nil)
        
//                resignFirstResponder()
        //        endEditing(true)
    }
    
    
    @objc func keyboarDidShown(notification: NSNotification){
        
        delegate?.keyboarDidShown(notification: notification)
        
        guard
            let holderView = holderView,
            let scrollV = scrollV,
            let holderWindow = holderWindow
            else {return}
        
        guard let keyboardFrame = keyboardFrame(userInfo: notification.userInfo) else {return}
        
        keyboardSize = keyboardFrame.size
        
        // check hardware keyboard
        let keyboard = scrollV.convert(keyboardFrame, to: holderWindow)
        let height = holderView.frame.size.height
        if ((keyboard.origin.y + keyboard.size.height) > height) {
            isHardwareKeyboardPresent = false
            //                    self.keyboardSize?.height = 0
            scrollV.contentSize.height = scrollV.bounds.height + keyboardFrame.height
        }else{
            isHardwareKeyboardPresent = true
            let toolbarHeight = height - keyboard.origin.y
            scrollV.contentSize.height = scrollV.bounds.height + toolbarHeight
        }
        
        // This detection is not accurate!!
        print("🔫 isHardwareKeyboardPresent: \(isHardwareKeyboardPresent)")
        
        
        scrollToCursor()
        
        
    }
    
    @objc func keyboardDidHide(notification: NSNotification){
        
        delegate?.keyboardDidHide(notification: notification)
        
        guard
            let holderView = holderView,
            let scrollV = scrollV,
            let holderWindow = holderWindow
            else {return}
        
        guard let keyboardFrame = keyboardFrame(userInfo: notification.userInfo) else {return}
        
        UIView.animate(withDuration: 0.3) {
            scrollV.contentSize.height = scrollV.bounds.height
        }
    }
    
    internal func keyboardFrame(userInfo:[AnyHashable : Any]?)->CGRect?{
        return userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect
    }
    public func scrollToCursor(){
        
        guard
            let holderView = holderView,
            let scrollV = scrollV,
            let holderWindow = holderWindow
            else {return}
        
        
        
        
        var targetPos:CGFloat?
        
        /// when textView is used.
        if let cursorPosition = textView?.selectedTextRange?.start {
            
            guard let rawText = textView else {return}
            print("======textView=======")
            
            // if you want to know its position in textView in points:
            let caretPositionRect = rawText.caretRect(for: cursorPosition)
            print("caretPositionRectY: \(caretPositionRect.maxY)")
            
            let textOffsetY = rawText.contentOffset.y
            print("rawText offsetY: \(textOffsetY)")
            
            let posOnWindowY = scrollV.convert(caretPositionRect, to: holderWindow).maxY
            print("posOnWindowY: \(posOnWindowY)")
            
            targetPos = posOnWindowY - textOffsetY + 40
            print("targetPos: \(String(describing: targetPos))\n")
            
        }else if let label = textLabel{
            
            print("======uilabel=======")
            
            let posOnWindowY = textLabel!.superview!.convert(label.frame, to: holderWindow).maxY + labelBottomPadding
            print("posOnWindowY: \(posOnWindowY)")
            
            targetPos = posOnWindowY
            print("targetPos: \(targetPos)\n")
            
        }else if let aView = aView{
            
            print("======aView=======")
           
            let posOnWindowY = aView.superview!.convert(aView.frame, to: holderWindow).maxY
            print("posOnWindowY: \(posOnWindowY)")
            
            targetPos = posOnWindowY
            print("targetPos: \(targetPos)\n")
        }
        
        
        guard let visiblePos = targetPos else { return }
        
            var keyboardCoordY:CGFloat  = 0
            guard let keyboardSize = keyboardSize else {return}
            
            keyboardCoordY = UIScreen.main.bounds.height - keyboardSize.height
            
            /// offsetY > 0 is fix the issue that text area scroll till top very first time
            if visiblePos > keyboardCoordY {
                print("under keyboard \(keyboardCoordY - visiblePos)")
                
                var contentOffset = scrollV.contentOffset.y - (keyboardCoordY - visiblePos)
                
                if contentOffset > keyboardSize.height{
                    contentOffset = keyboardSize.height
                }
                
                UIView.animate(withDuration: 0.5) {
                    scrollV.contentOffset.y = contentOffset
                    
                }
            }
        
    }
    
}
