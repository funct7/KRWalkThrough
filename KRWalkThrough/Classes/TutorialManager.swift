//
//  TutorialManager.swift
//  Tutorial
//
//  Created by Joshua Park on 5/27/16.
//  Copyright © 2016 Knowre. All rights reserved.
//

import UIKit

open class TutorialManager: NSObject {
    
    @objc
    open static let shared = TutorialManager()
    
    open var shouldShowTutorial = true
    open private(set) var items = [String: TutorialItem]()
    open private(set) var currentItem: TutorialItem?
    
    fileprivate let blankItem: TutorialItem
    fileprivate let transparentItem: TutorialItem
    
    fileprivate override init() {
        let blankView = TutorialView(frame: UIScreen.main.bounds)
        blankItem = TutorialItem(view: blankView, identifier: "blankItem")
        
        let transparentView = TutorialView(frame: UIScreen.main.bounds)
        transparentView.backgroundColor = UIColor.clear
        transparentItem = TutorialItem(view: transparentView, identifier: "transparentItem")
    }
    
    @objc
    open func register(item: TutorialItem) {
        items[item.identifier] = item
    }

    @objc
    open func deregister(item: TutorialItem) {
        items[item.identifier] = nil
    }

    @objc
    open func deregisterAllItems() {
        for key in items.keys {
            items[key] = nil
        }
    }

    @objc
    open func performNextAction() {
        currentItem?.nextAction?()
    }

    @objc
    open func showTutorial(withIdentifier identifier: String) {
        guard shouldShowTutorial else {
            print("TutorialManager.shouldShowTutorial = false\nTutorial Manager will return without showing tutorial.")
            return
        }
        
        guard let window = UIApplication.shared.delegate?.window else {
            fatalError("UIApplication delegate's window is missing.")
        }
        
        guard let item = items[identifier] else {
            print("ERROR: \(TutorialManager.self) line #\(#line) - \(#function)\n** Reason: No registered item with identifier: \(identifier)")
            return
        }
        
        if blankItem.view.superview != nil { blankItem.view.removeFromSuperview() }
        if transparentItem.view.superview != nil { transparentItem.view.removeFromSuperview() }
        window?.addSubview(item.view)
        window?.setNeedsLayout()
        
        if currentItem?.view.superview != nil { currentItem?.view.removeFromSuperview() }
        currentItem = item
    }

    @objc
    open func showBlankItem(withAction action: Bool = false) {
        UIApplication.shared.delegate!.window!!.addSubview(blankItem.view)
        UIApplication.shared.delegate!.window!!.setNeedsLayout()
        
        if action { currentItem?.nextAction?() }
        currentItem?.view.removeFromSuperview()
        currentItem = nil
    }

    @objc
    open func showTransparentItem(withAction action: Bool = false) {
        UIApplication.shared.delegate!.window!!.addSubview(transparentItem.view)
        UIApplication.shared.delegate!.window!!.setNeedsLayout()
        
        if action { currentItem?.nextAction?() }
        currentItem?.view.removeFromSuperview()
        currentItem = nil
    }

    @objc
    open func hideTutorial(withAction action: Bool = false) {
        if action { currentItem?.nextAction?() }
        currentItem?.view.removeFromSuperview()
        currentItem = nil
    }
}
