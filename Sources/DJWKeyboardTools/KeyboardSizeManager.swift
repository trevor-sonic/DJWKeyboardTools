//
//  KeyboardSizeManager.swift
//  Stage2
//
//  Created by dejaWorks on 10/07/2019.
//  Copyright © 2019 dejaWorks. All rights reserved.
//

import UIKit
import SnapKit

// MARK: - Keyboard Size Manager
public protocol KeyboardSizeManagerDelegate:class {
    func setupKeyboardSizer()
    func registerForKeyboardNotifications()
    func unregisterFromKeyboardNotifications()
    func keyboarDidShown(notification: NSNotification)
    func keyboardDidHide(notification: NSNotification)
}

open class KeyboardSizeManager:NSObject {
    
    public weak var delegate:KeyboardSizeManagerDelegate?
    
    public var isHardwareKeyboardPresent:Bool = false
    public var keyboardSize:CGSize?
    public var holderWindow:UIWindow?
    public var holderView:UIView?
    public var scrollV:UIScrollView?
    
    public var textView:UITextView?
    public var textLabel:UILabel?
    public var aView:UIView?
    public var autoScrollBack:Bool = true
    
    /// TextView bottom constraints is modified by KeyboardSizeManager therfore original distance must be provided.
    public var originalTextViewBottomConstraintsOffset:CGFloat = -10 // a default value
    
    private var contentOffsetOriginalYPosition:CGFloat?
    
    /// Padding when textLabel is used, bottom pading.
    public var labelBottomPadding:CGFloat = 48.0
    
    open func registerForKeyboardNotifications(){
        //Adding notifies on keyboard show
        NotificationCenter.default.addObserver(self, selector: #selector(keyboarDidShown(notification:)), name: UIResponder.keyboardDidShowNotification, object: nil)
        
        //Adding notifies on keyboard hide
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardDidHide(notification:)), name: UIResponder.keyboardDidHideNotification, object: nil)
    }
    
    open func unregisterFromKeyboardNotifications(){
        //Removing notifies on keyboard appearing
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardDidShowNotification, object: nil)
        
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardDidHideNotification, object: nil)
        
//                resignFirstResponder()
        //        endEditing(true)
    }
    
    
    @objc open func keyboarDidShown(notification: NSNotification){
        
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
            ///x scrollV.contentSize.height = scrollV.bounds.height + keyboardFrame.height
        }else{
            isHardwareKeyboardPresent = true
            //let toolbarHeight = height - keyboard.origin.y
            ///x scrollV.contentSize.height = scrollV.bounds.height + toolbarHeight
        }
        
        // This detection is not accurate!!
        print("🔫 isHardwareKeyboardPresent: \(isHardwareKeyboardPresent)")
        
        
        scrollToCursor()
        
        
    }
    
    @objc open func keyboardDidHide(notification: NSNotification){
        
        delegate?.keyboardDidHide(notification: notification)
        restoreTextViewSize()
        
        
        guard
            let scrollV = scrollV,
            let _ = holderWindow
            else {return}
        
        guard let _ = keyboardFrame(userInfo: notification.userInfo) else {return}
        guard let contentOffset = contentOffsetOriginalYPosition, autoScrollBack else {return}
        
        
        UIView.animate(withDuration: 0.3) {
            ///x scrollV.contentSize.height = scrollV.bounds.height
            scrollV.contentOffset.y = contentOffset
        }
        
        
    }
    
    internal func keyboardFrame(userInfo:[AnyHashable : Any]?)->CGRect?{
        return userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect
    }
    // MARK: - When TextView is used
    func restoreTextViewSize(){
        guard
            let textView = textView,
            let superView = textView.superview
            else {return}
        
        UIView.animate(withDuration: 0.2) {
            textView.snp.updateConstraints({ make in
                if #available(iOS 11, *) {
                    make.bottom.equalTo(superView.safeAreaLayoutGuide.snp.bottomMargin)
                }else{
                    make.bottom.equalToSuperview().offset(self.originalTextViewBottomConstraintsOffset)
                }
            })
            self.textView?.superview?.layoutIfNeeded()
        }
    }
    
    /// Lift the bottom of textView over the keyboard
    func resizeTextView(){
        guard let keyboardH = keyboardSize?.height else {return}
        let offset = keyboardH + 8 // some padding
       
        guard
        let textView = textView,
        let superView = textView.superview
        else {return}
        
        UIView.animate(withDuration: 0.2) {
            textView.snp.updateConstraints({ make in
                
                if #available(iOS 11, *) {
                    make.bottom.equalTo(superView.safeAreaLayoutGuide.snp.bottomMargin).offset(-offset + 20)
                }else{
                    make.bottom.equalToSuperview().offset(-offset)
                }
            })
            superView.layoutIfNeeded()
        }
    }
    
    public func scrollToCursor(){
        
        guard
            let _ = holderView,
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
            print("caretPositionRectY: \(caretPositionRect.origin.y)")
            
            let textOffsetY = rawText.contentOffset.y
            print("rawText offsetY: \(textOffsetY)")
            
            let posOnWindowY = scrollV.convert(caretPositionRect, to: holderWindow).origin.y
            print("posOnWindowY: \(posOnWindowY)")

            targetPos = posOnWindowY - textOffsetY + 40
            
            scrollTheTextViewTo(targetPos: targetPos)

//            print("targetPos: \(String(describing: targetPos))\n")
            
        }else if let label = textLabel{
            
            guard let superView = label.superview else {
                print("📛 label.superview is NIL \(#function) in\(self.description)")
                return
            }
            
            print("======uilabel=======")
            
            let posOnWindowY = superView.convert(label.frame, to: holderWindow).origin.y + labelBottomPadding
            
            print("Label Y pos: \(String(describing: superView.convert(label.frame, to: holderWindow).origin.y))")
            
            
            print("posOnWindowY: \(posOnWindowY)")
            print("scrollV.contentOffset: \(String(describing: scrollV.contentOffset))")
            targetPos = posOnWindowY
            scrollTheScrollViewTo(targetPos: targetPos)
            
            
        }else if let aView = aView{
            
            print("======aView=======")
            
            let posOnWindowY = aView.superview!.convert(aView.frame, to: holderWindow).maxY
            print("posOnWindowY: \(posOnWindowY)")
            
            targetPos = posOnWindowY
            scrollTheScrollViewTo(targetPos: targetPos)
        }
        
        
        
        
        
    }
    private func scrollTheTextViewTo(targetPos:CGFloat?){
        //print("⚠️ Implement targetPos \(targetPos) \(#function) in \(description)")
        
        
        
        resizeTextView()
        
    }
    private func scrollTheScrollViewTo(targetPos:CGFloat?){
        var keyboardCoordY:CGFloat  = 0
        guard
            let keyboardSize = keyboardSize,
            let visiblePos = targetPos,
            let scrollV = scrollV
            else {return}
      
        
        /// keyboard's y position on screen
        keyboardCoordY = UIScreen.main.bounds.height - keyboardSize.height
        
        /// offsetY > 0 is fix the issue that text area scroll till top very first time
        if visiblePos > keyboardCoordY {
            
            print("visiblePos > keyboardCoordY so it is under keyboard.")
            
            /// save original pos. to scroll back
            contentOffsetOriginalYPosition = scrollV.contentOffset.y
            
            let hiddenPartHeight =  visiblePos - keyboardCoordY
            // print("hiddenPartHeight \(hiddenPartHeight)")
            
            /// Scroll distance over the scroll content offset
            let contentOffset = scrollV.contentOffset.y + hiddenPartHeight
            
            UIView.animate(withDuration: 0.5) {
                scrollV.contentOffset.y = contentOffset
                
            }
        }else{
            print("visiblePos < keyboardCoordY so it is visible \(visiblePos), \(keyboardCoordY).")
        }
    }
}
