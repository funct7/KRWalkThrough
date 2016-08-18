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
    
    @IBOutlet public weak var prevButton: UIControl?
    @IBOutlet public weak var nextButton: UIControl?
    public override var backgroundColor: UIColor? {
        get {
            return fillColor
        }
        set {
            if let color = newValue { fillColor = color }
        }
    }
    public override var frame: CGRect {
        didSet {
            if frame != oldValue {
                if var touchArea = touchArea {
                    let hScale = frame.width / oldValue.width
                    let vScale = frame.height / oldValue.height
                        
                    touchArea.origin.x *= hScale
                    touchArea.origin.y *= vScale
                    self.touchArea = touchArea
                    
                    if var maskRect = maskRect {
                        maskRect.origin.x *= hScale
                        maskRect.origin.y *= vScale
                        
                        self.maskRect = maskRect
                    }
                }
            }
        }
    }
    
    //: The area that receives touch as defined by the view upon initialization
    //: touchArea and nextButton should be mutally exclusive
    private var fillColor = UIColor(white: 0.0, alpha: 0.5)
    private var touchArea: CGRect?
    private var maskRect: CGRect?
    private var cornerRadius: CGFloat?
    
    public func makeAvailable(view: UIView) {
        let frame = convertRect(view.frame, fromView: view.superview)
        makeAvailable(frame, maskRect: frame, cornerRadius: 0.0)
    }
    
    //: Makes a circle-shaped available area with the given radius inset
    public func makeAvailable(view: UIView, radiusInset: CGFloat) {
        if !view.translatesAutoresizingMaskIntoConstraints {
            view.superview?.layoutIfNeeded()
        }
        
        let rect = convertRect(view.frame, fromView: view.superview)
        let center = convertPoint(view.center, fromView: view.superview)
        let rawDiameter = sqrt(pow(view.frame.width, 2) + pow(view.frame.height, 2))
        let diameter = round(rawDiameter) + radiusInset * 2.0
        
        let x = center.x - diameter / 2.0
        let y = center.y - diameter / 2.0
        
        makeAvailable(rect, maskRect: CGRectMake(x, y, diameter, diameter), cornerRadius: diameter/2.0)
    }
    
    public func makeAvailable(view: UIView, insets: UIEdgeInsets, cornerRadius: CGFloat) {
        if !view.translatesAutoresizingMaskIntoConstraints {
            view.superview?.layoutIfNeeded()
        }
        
        let rect = convertRect(view.frame, fromView: view.superview)
        var maskRect = rect
        maskRect.origin.x -= insets.left
        maskRect.origin.y -= insets.top
        maskRect.size.width += insets.left + insets.right
        maskRect.size.height += insets.top + insets.bottom
        
        makeAvailable(rect, maskRect: maskRect, cornerRadius: cornerRadius)
    }
    
    public func makeAvailable(rect: CGRect, cornerRadius: CGFloat) {
        makeAvailable(rect, maskRect: rect, cornerRadius: cornerRadius)
    }
    
    public func makeAvailable(rect: CGRect, maskRect: CGRect, cornerRadius: CGFloat) {
        touchArea = rect
        self.maskRect = maskRect
        self.cornerRadius = cornerRadius
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        
        for layer in self.layer.sublayers ?? [] {
            if layer.name == "TutorialView.backgroundLayer" {
                layer.removeFromSuperlayer()
            }
        }
        
        let path = UIBezierPath(rect: bounds)
        if let maskRect = maskRect, let cornerRadius = cornerRadius {
            path.appendPath(UIBezierPath(roundedRect: maskRect, cornerRadius: cornerRadius))
        }
        
        let backgroundLayer = CAShapeLayer()
        backgroundLayer.fillColor = fillColor.CGColor
        backgroundLayer.fillRule = kCAFillRuleEvenOdd
        backgroundLayer.frame = bounds
        backgroundLayer.name = "TutorialView.backgroundLayer"
        backgroundLayer.path = path.CGPath
        
        layer.insertSublayer(backgroundLayer, atIndex: 0)
    }
    
    public override func hitTest(point: CGPoint, withEvent event: UIEvent?) -> UIView? {
        if let touchArea = touchArea where CGRectContainsPoint(touchArea, point) {
            return nil
        }
        return super.hitTest(point, withEvent: event)
    }
}

// ===========================
// MARK: - Tutorial Item
// ===========================

public class TutorialItem: NSObject {
    public let identifier: String
    
    public var prevAction: (() -> Void)?
    public var nextAction: (() -> Void)?
    
    public let view: TutorialView
    
    public init(view: TutorialView, identifier: String) {
        assert(!identifier.isEmpty, "Tutorial view must have a valid identifier.")
        self.view = view
        self.identifier = identifier
        super.init()
        prepareView()
    }
    
    public init(nibName: String, identifier: String) {
        assert(!identifier.isEmpty, "Tutorial view must have a valid identifier.")
        self.view = NSBundle.mainBundle().loadNibNamed(nibName, owner: nil, options: nil)[0] as! TutorialView
        self.identifier = identifier
        super.init()
        prepareView()
    }
    
    public init(storyboardName: String, storyboardID: String, identifier: String) {
        assert(!identifier.isEmpty, "Tutorial view must have a valid identifier.")
        let vc = UIStoryboard(name: storyboardName, bundle: nil).instantiateViewControllerWithIdentifier(storyboardID)
        self.view = vc.view as! TutorialView
        self.identifier = identifier
        super.init()
        prepareView()
    }
    
    private func prepareView() {
        view.item = self
        
        if let prevButton = view.prevButton {
            prevButton.addTarget(self, action: #selector(prevButtonAction), forControlEvents: .TouchUpInside)
        }
        
        if let nextButton = view.nextButton {
            nextButton.addTarget(self, action: #selector(nextButtonAction), forControlEvents: .TouchUpInside)
        }
    }
    
    @objc private func prevButtonAction(sender: AnyObject) {
        if let prevAction = prevAction {
            prevAction()
        } else {
            print("ERROR: \(TutorialItem.self) line #\(#line) - \(#function)\n** Reason: No action has been set.")
        }
    }
    
    @objc private func nextButtonAction(sender: AnyObject) {
        if let nextAction = nextAction {
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
    private let transparentItem: TutorialItem
    
    private override init() {
        let blankView = TutorialView(frame: UIScreen.mainScreen().bounds)
        blankItem = TutorialItem(view: blankView, identifier: "blankItem")
        
        let transparentView = TutorialView(frame: UIScreen.mainScreen().bounds)
        transparentView.backgroundColor = UIColor.clearColor()
        transparentItem = TutorialItem(view: transparentView, identifier: "transparentItem")
    }
    
    public func registerItem(item: TutorialItem) {
        items[item.identifier] = item
    }
    
    public func performNextAction() {
        currentItem?.nextAction?()
    }
    
    public func showTutorialWithIdentifier(tutorialID: String) {
        guard shouldShowTutorial else {
            print("TutorialManager.shouldShowTutorial = false\nTutorial Manager will return without showing tutorial.")
            return
        }
        
        guard let window = UIApplication.sharedApplication().delegate?.window else {
            fatalError("UIApplication delegate's window is missing.")
        }
        
        guard let item = items[tutorialID] else {
            print("ERROR: \(TutorialManager.self) line #\(#line) - \(#function)\n** Reason: No registered item with identifier: \(tutorialID)")
            return
        }
        
        if blankItem.view.superview != nil { blankItem.view.removeFromSuperview() }
        if transparentItem.view.superview != nil { transparentItem.view.removeFromSuperview() }
        window?.addSubview(item.view)
        window?.setNeedsLayout()
        
        if currentItem?.view.superview != nil { currentItem?.view.removeFromSuperview() }
        currentItem = item
    }
    
    public func showBlankItem(performNextAction: Bool = false) {
        UIApplication.sharedApplication().delegate!.window!!.addSubview(blankItem.view)
        UIApplication.sharedApplication().delegate!.window!!.setNeedsLayout()
        
        if performNextAction { currentItem?.nextAction?() }
        currentItem?.view.removeFromSuperview()
        currentItem = nil
    }
    
    public func showTransparentItem(performNextAction: Bool = false) {
        UIApplication.sharedApplication().delegate!.window!!.addSubview(transparentItem.view)
        UIApplication.sharedApplication().delegate!.window!!.setNeedsLayout()
        
        if performNextAction { currentItem?.nextAction?() }
        currentItem?.view.removeFromSuperview()
        currentItem = nil
    }
    
    public func hideTutorial(performNextAction: Bool = false) {
        if performNextAction { currentItem?.nextAction?() }
        currentItem?.view.removeFromSuperview()
        currentItem = nil
    }
}
