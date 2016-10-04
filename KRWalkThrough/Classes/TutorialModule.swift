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

open class TutorialView: UIView {
    open weak var item: TutorialItem!
    
    @IBOutlet open weak var prevButton: UIButton?
    @IBOutlet open weak var nextButton: UIButton?
    open override var backgroundColor: UIColor? {
        get {
            return fillColor
        }
        set {
            if let color = newValue { fillColor = color }
        }
    }
    open override var frame: CGRect {
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
    fileprivate var fillColor = UIColor(white: 0.0, alpha: 0.5)
    fileprivate var touchArea: CGRect?
    fileprivate var maskRect: CGRect?
    fileprivate var cornerRadius: CGFloat?
    
    open func makeAvailable(_ view: UIView) {
        let frame = convert(view.frame, from: view.superview)
        makeAvailable(frame, maskRect: frame, cornerRadius: 0.0)
    }
    
    //: Makes a circle-shaped available area with the given radius inset
    open func makeAvailable(_ view: UIView, radiusInset: CGFloat) {
        if !view.translatesAutoresizingMaskIntoConstraints {
            view.superview?.layoutIfNeeded()
        }
        
        let rect = convert(view.frame, from: view.superview)
        let center = convert(view.center, from: view.superview)
        let rawDiameter = sqrt(pow(view.frame.width, 2) + pow(view.frame.height, 2))
        let diameter = round(rawDiameter) + radiusInset * 2.0
        
        let x = center.x - diameter / 2.0
        let y = center.y - diameter / 2.0
        
        makeAvailable(rect, maskRect: CGRect(x: x, y: y, width: diameter, height: diameter), cornerRadius: diameter/2.0)
    }
    
    open func makeAvailable(_ view: UIView, insets: UIEdgeInsets, cornerRadius: CGFloat) {
        if !view.translatesAutoresizingMaskIntoConstraints {
            view.superview?.layoutIfNeeded()
        }
        
        let rect = convert(view.frame, from: view.superview)
        var maskRect = rect
        maskRect.origin.x -= insets.left
        maskRect.origin.y -= insets.top
        maskRect.size.width += insets.left + insets.right
        maskRect.size.height += insets.top + insets.bottom
        
        makeAvailable(rect, maskRect: maskRect, cornerRadius: cornerRadius)
    }
    
    open func makeAvailable(_ rect: CGRect, cornerRadius: CGFloat) {
        makeAvailable(rect, maskRect: rect, cornerRadius: cornerRadius)
    }
    
    open func makeAvailable(_ rect: CGRect, maskRect: CGRect, cornerRadius: CGFloat) {
        touchArea = rect
        self.maskRect = maskRect
        self.cornerRadius = cornerRadius
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        
        for layer in self.layer.sublayers ?? [] {
            if layer.name == "TutorialView.backgroundLayer" {
                layer.removeFromSuperlayer()
            }
        }
        
        let path = UIBezierPath(rect: bounds)
        if let maskRect = maskRect, let cornerRadius = cornerRadius {
            path.append(UIBezierPath(roundedRect: maskRect, cornerRadius: cornerRadius))
        }
        
        let backgroundLayer = CAShapeLayer()
        backgroundLayer.fillColor = fillColor.cgColor
        backgroundLayer.fillRule = kCAFillRuleEvenOdd
        backgroundLayer.frame = bounds
        backgroundLayer.name = "TutorialView.backgroundLayer"
        backgroundLayer.path = path.cgPath
        
        layer.insertSublayer(backgroundLayer, at: 0)
    }
    
    open override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        if let touchArea = touchArea , touchArea.contains(point) {
            return nil
        }
        return super.hitTest(point, with: event)
    }
}

// ===========================
// MARK: - Tutorial Item
// ===========================

open class TutorialItem: NSObject {
    open let tutorialID: String
    
    open var prevAction: (() -> Void)?
    open var nextAction: (() -> Void)?
    
    open let view: TutorialView
    
    public init(view: TutorialView, identifier: String) {
        assert(!identifier.isEmpty, "Tutorial view must have a valid identifier.")
        self.view = view
        self.tutorialID = identifier
        super.init()
        prepareView()
    }
    
    public init(nibName: String, identifier: String) {
        assert(!identifier.isEmpty, "Tutorial view must have a valid identifier.")
        self.view = Bundle.main.loadNibNamed(nibName, owner: nil, options: nil)?[0] as! TutorialView
        self.tutorialID = identifier
        super.init()
        prepareView()
    }
    
    fileprivate func prepareView() {
        view.item = self
        
        if let prevButton = view.prevButton {
            prevButton.addTarget(self, action: #selector(prevButtonAction), for: .touchUpInside)
        }
        
        if let nextButton = view.nextButton {
            nextButton.addTarget(self, action: #selector(nextButtonAction), for: .touchUpInside)
        }
    }
    
    @objc fileprivate func prevButtonAction(_ sender: AnyObject) {
        if let prevAction = prevAction {
            prevAction()
        } else {
            print("ERROR: \(TutorialItem.self) line #\(#line) - \(#function)\n** Reason: No action has been set.")
        }
    }
    
    @objc fileprivate func nextButtonAction(_ sender: AnyObject) {
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

open class TutorialManager: NSObject {
    open static func sharedManager() -> TutorialManager { return _sharedManager }
    fileprivate static let _sharedManager = TutorialManager()
    
    open var shouldShowTutorial = true
    open var items = [String: TutorialItem]()
    open fileprivate(set) var currentItem: TutorialItem?
    
    fileprivate let blankItem: TutorialItem
    fileprivate let transparentItem: TutorialItem
    
    fileprivate override init() {
        let blankView = TutorialView(frame: UIScreen.main.bounds)
        blankItem = TutorialItem(view: blankView, identifier: "blankItem")
        
        let transparentView = TutorialView(frame: UIScreen.main.bounds)
        transparentView.backgroundColor = UIColor.clear
        transparentItem = TutorialItem(view: transparentView, identifier: "transparentItem")
    }
    
    open func registerItem(_ item: TutorialItem) {
        items[item.tutorialID] = item
    }
    
    open func showTutorialWithIdentifier(_ tutorialID: String) {
        if !shouldShowTutorial {
            print("TutorialManager.shouldShowTutorial = false\nTutorial Manager will return without showing tutorial.")
            return
        }
        
        if let window = UIApplication.shared.delegate?.window {
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
    
    open func showBlankItem() {
        UIApplication.shared.delegate!.window!!.addSubview(blankItem.view)
        UIApplication.shared.delegate!.window!!.setNeedsLayout()
        
        currentItem?.nextAction?()
        currentItem?.view.removeFromSuperview()
        currentItem = nil
    }
    
    open func showTransparentItem() {
        UIApplication.shared.delegate!.window!!.addSubview(transparentItem.view)
        UIApplication.shared.delegate!.window!!.setNeedsLayout()
        
        currentItem?.nextAction?()
        currentItem?.view.removeFromSuperview()
        currentItem = nil
    }
    
    open func hideTutorial() {
        currentItem?.nextAction?()
        currentItem?.view.removeFromSuperview()
        currentItem = nil
    }
}
