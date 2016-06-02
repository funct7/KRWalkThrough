//
//  TutorialModule.swift
//  Tutorial
//
//  Created by Joshua Park on 5/27/16.
//  Copyright © 2016 Knowre. All rights reserved.
//

import UIKit

// ===========================
// MARK: - Tutorial View
// ===========================

public class TutorialView: UIView {
    public weak var item: TutorialItem!
    
    @IBOutlet public weak var prevButton: UIButton?
    @IBOutlet public weak var nextButton: UIButton?
    
    public override var backgroundColor: UIColor? {
        get {
            return UIColor(CGColor: self.backgroundLayer.fillColor!)
        }
        set {
            self.backgroundLayer.fillColor = newValue?.CGColor
        }
    }
    
    //: The area that receives touch as defined by the view upon initialization
    //: touchArea and nextButton should be mutally exclusive
    private var touchArea: CGRect?
    
    private weak var backgroundLayer: CAShapeLayer!
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.prepareSubviews()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        self.prepareSubviews()
    }
    
    public func makeAvailable(view: UIView) {
        let frame = self.convertRect(view.frame, fromView: view.superview)
        self.makeAvailable(frame, maskRect: frame, cornerRadius: 0.0)
    }
    
    //: Makes a circle-shaped available area with the given radius inset
    public func makeAvailable(view: UIView, radiusInset: CGFloat) {
        let frame = self.convertRect(view.frame, fromView: view.superview)
        let center = self.convertPoint(view.center, fromView: view.superview)
        let rawDiameter = sqrt(pow(view.frame.width, 2) + pow(view.frame.height, 2))
        let diameter = round(rawDiameter) + radiusInset * 2.0
        
        let x = center.x - diameter / 2.0
        let y = center.y - diameter / 2.0
        
        self.makeAvailable(frame, maskRect: CGRectMake(x, y, diameter, diameter), cornerRadius: diameter/2.0)
    }
    
    public func makeAvailable(rect: CGRect, cornerRadius: CGFloat) {
        self.makeAvailable(rect, maskRect: rect, cornerRadius: cornerRadius)
    }
    
    public func makeAvailable(rect: CGRect, maskRect: CGRect, cornerRadius: CGFloat) {
        let subPath = UIBezierPath(roundedRect: maskRect, cornerRadius: cornerRadius)
        let path = UIBezierPath(rect: self.bounds)
        path.appendPath(subPath)
        
        self.backgroundLayer.path = path.CGPath
        
        self.touchArea = rect
    }
    
    private func prepareSubviews() {
        let backgroundLayer = CAShapeLayer()
        backgroundLayer.frame = self.bounds
        backgroundLayer.path = UIBezierPath(rect: self.bounds).CGPath
        backgroundLayer.fillColor = UIColor(white: 0.0, alpha: 0.5).CGColor
        backgroundLayer.fillRule = kCAFillRuleEvenOdd
        self.layer.addSublayer(backgroundLayer)
        self.backgroundLayer = backgroundLayer
    }
    
    public override func hitTest(point: CGPoint, withEvent event: UIEvent?) -> UIView? {
        if let touchArea = self.touchArea where CGRectContainsPoint(touchArea, point) {
            return nil
        }
        return super.hitTest(point, withEvent: event)
    }
}

// ===========================
// MARK: - Tutorial Item
// ===========================

public class TutorialItem: NSObject {
    public let tutorialID: String
    
    public var prevAction: (() -> Void)?
    public var nextAction: (() -> Void)?
    
    public let view: TutorialView
    
    public init(view: TutorialView, identifier: String) {
        assert(!identifier.isEmpty, "Tutorial view must have a valid identifier.")
        self.view = view
        self.tutorialID = identifier
        super.init()
        self.prepareView()
    }
    
    public init(nibName: String, identifier: String) {
        assert(!identifier.isEmpty, "Tutorial view must have a valid identifier.")
        self.view = NSBundle.mainBundle().loadNibNamed(nibName, owner: nil, options: nil)[0] as! TutorialView
        self.tutorialID = identifier
        super.init()
        self.prepareView()
    }
    
    private func prepareView() {
        self.view.item = self
        
        if let prevButton = self.view.prevButton {
            prevButton.addTarget(self, action: #selector(prevButtonAction), forControlEvents: .TouchUpInside)
        }
        
        if let nextButton = self.view.nextButton {
            nextButton.addTarget(self, action: #selector(nextButtonAction), forControlEvents: .TouchUpInside)
        }
    }
    
    @objc private func prevButtonAction(sender: AnyObject) {
        if let prevAction = self.prevAction {
            prevAction()
        } else {
            print("ERROR: \(TutorialItem.self) line #\(#line) - \(#function)\n** Reason: No action has been set.")
        }
    }
    
    @objc private func nextButtonAction(sender: AnyObject) {
        if let nextAction = self.nextAction {
            nextAction()
        } else {
            print("ERROR: \(TutorialItem.self) line #\(#line) - \(#function)\n** Reason: No action has been set.")
        }
    }
}

// ==============================
// MARK: - Tutorial Manager
// ==============================

public class TutorialManager: NSObject {
    public static func sharedManager() -> TutorialManager { return _sharedManager }
    private static let _sharedManager = TutorialManager()
    
    public var shouldShowTutorial = true
    public var items = [String: TutorialItem]()
    public private(set) var currentItem: TutorialItem?
    
    private let blankItem: TutorialItem
    
    private override init() {
        let tutorialView = TutorialView(frame: UIScreen.mainScreen().bounds)
        self.blankItem = TutorialItem(view: tutorialView, identifier: "blankItem")
    }
    
    public func registerItem(item: TutorialItem) {
        self.items[item.tutorialID] = item
    }
    
    public func showTutorialWithIdentifier(tutorialID: String) {
        if !self.shouldShowTutorial {
            print("TutorialManager.shouldShowTutorial = false\nTutorial Manager will return without showing tutorial.")
            return
        }
        
        if let window = UIApplication.sharedApplication().delegate?.window {
            if let item = self.items[tutorialID] {
                self.blankItem.view.removeFromSuperview()
                window?.addSubview(item.view)
                
                self.currentItem?.view.removeFromSuperview()
                self.currentItem = item
            } else {
                print("ERROR: \(TutorialManager.self) line #\(#line) - \(#function)\n** Reason: No registered item with identifier: \(tutorialID)")
            }
        }
    }
    
    public func showBlankItem() {
        UIApplication.sharedApplication().delegate!.window!!.addSubview(self.blankItem.view)
        self.currentItem?.nextAction?()
        self.currentItem?.view.removeFromSuperview()
        self.currentItem = nil
    }
    
    public func hideTutorial() {
        self.currentItem?.nextAction?()
        self.currentItem?.view.removeFromSuperview()
        self.currentItem = nil
    }
}
