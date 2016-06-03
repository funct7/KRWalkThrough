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
    
    public var animationScale: CGFloat = 1.0
    
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
            if layer.name == "TutorialView.backgroundLayer" || layer.name == "TutorialView.animationLayer" {
                layer.removeFromSuperlayer()
            }
        }
        
        let path = UIBezierPath(rect: bounds)
        if let maskRect = maskRect, let cornerRadius = cornerRadius {
            let subPath = UIBezierPath(roundedRect: maskRect, cornerRadius: cornerRadius)
            path.appendPath(subPath)
            
            if let animationLayer = getAnimationLayer() {
                layer.insertSublayer(animationLayer, atIndex: 0)
            }
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
    
    private func getAnimationLayer() -> CAShapeLayer? {
        guard let maskRect = maskRect, let cornerRadius = cornerRadius where animationScale > 1.0 else {
            return nil
        }
        let subPath = UIBezierPath(roundedRect: maskRect, cornerRadius: cornerRadius)
        
        let animationLayer = CAShapeLayer()
        animationLayer.strokeColor = UIColor.whiteColor().CGColor
        animationLayer.fillColor = UIColor.clearColor().CGColor
        animationLayer.lineWidth = 1.0
        animationLayer.name = "TutorialView.animationLayer"
        animationLayer.path = subPath.CGPath

        var biggerRect = maskRect
        let offsetScale = (animationScale - 1.0) / 2.0
        biggerRect.origin.x -= biggerRect.width * offsetScale
        biggerRect.origin.y -= biggerRect.height * offsetScale
        biggerRect.size.width *= animationScale
        biggerRect.size.height *= animationScale
        
        let animFocus = CABasicAnimation(keyPath: "path")
        animFocus.fromValue = UIBezierPath(roundedRect: biggerRect, cornerRadius: cornerRadius * 1.25).CGPath
        animFocus.toValue = subPath.CGPath
        animFocus.delegate = self
        animFocus.duration = 0.75
        animFocus.repeatCount = Float.infinity
        animationLayer.addAnimation(animFocus, forKey: nil)
        
        let animLine = CABasicAnimation(keyPath: "lineWidth")
        animLine.fromValue = 2.0
        animLine.toValue = 0.0
        animLine.duration = 0.75
        animLine.repeatCount = Float.infinity
        animationLayer.addAnimation(animLine, forKey: nil)
        
        let animOpacity = CABasicAnimation(keyPath: "opacity")
        animOpacity.fromValue = 0.25
        animOpacity.toValue = 0.95
        animOpacity.duration = 0.75
        animOpacity.repeatCount = Float.infinity
        animationLayer.addAnimation(animOpacity, forKey: nil)
        
        return animationLayer
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
        prepareView()
    }
    
    public init(nibName: String, identifier: String) {
        assert(!identifier.isEmpty, "Tutorial view must have a valid identifier.")
        self.view = NSBundle.mainBundle().loadNibNamed(nibName, owner: nil, options: nil)[0] as! TutorialView
        self.tutorialID = identifier
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
        items[item.tutorialID] = item
    }
    
    public func showTutorialWithIdentifier(tutorialID: String) {
        if !shouldShowTutorial {
            print("TutorialManager.shouldShowTutorial = false\nTutorial Manager will return without showing tutorial.")
            return
        }
        
        if let window = UIApplication.sharedApplication().delegate?.window {
            if let item = items[tutorialID] {
                blankItem.view.removeFromSuperview()
                transparentItem.view.removeFromSuperview()
                window?.addSubview(item.view)
                window?.setNeedsLayout()
                
                currentItem?.view.removeFromSuperview()
                currentItem = item
            } else {
                print("ERROR: \(TutorialManager.self) line #\(#line) - \(#function)\n** Reason: No registered item with identifier: \(tutorialID)")
            }
        }
    }
    
    public func showBlankItem() {
        UIApplication.sharedApplication().delegate!.window!!.addSubview(blankItem.view)
        UIApplication.sharedApplication().delegate!.window!!.setNeedsLayout()
        
        currentItem?.nextAction?()
        currentItem?.view.removeFromSuperview()
        currentItem = nil
    }
    
    public func showTransparentItem() {
        UIApplication.sharedApplication().delegate!.window!!.addSubview(transparentItem.view)
        UIApplication.sharedApplication().delegate!.window!!.setNeedsLayout()
        
        currentItem?.nextAction?()
        currentItem?.view.removeFromSuperview()
        currentItem = nil
    }
    
    public func hideTutorial() {
        currentItem?.nextAction?()
        currentItem?.view.removeFromSuperview()
        currentItem = nil
    }
}
