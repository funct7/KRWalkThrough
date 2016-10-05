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
    private enum TouchArea {
        case view(view: UIView)
        case rect(rect: CGRect)
    }
    
    private enum MaskArea {
        case rect(insets: UIEdgeInsets, cornerRadius: CGFloat)
        case radiusInset(radiusInset: CGFloat)
    }
    
    private typealias FocusType = (touch: TouchArea, mask: MaskArea)
    
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
    
    private var fillColor = UIColor(white: 0.0, alpha: 0.5)
    private var focus: FocusType?
    
    open func makeAvailable(view: UIView) {
        makeAvailable(view: view, insets: UIEdgeInsets.zero, cornerRadius: 0.0)
    }
    
    //: Makes a circle-shaped available area with the given radius inset
    open func makeAvailable(view: UIView, radiusInset: CGFloat) {
        let rect = convert(view.frame, from: view.superview)
        let center = convert(view.center, from: view.superview)
        let rawDiameter = sqrt(pow(view.frame.width, 2) + pow(view.frame.height, 2))
        let diameter = round(rawDiameter) + radiusInset * 2.0
        
        let x = center.x - diameter / 2.0
        let y = center.y - diameter / 2.0
        
        focus = (TouchArea.view(view: view), MaskArea.radiusInset(radiusInset: radiusInset))
    }
    
    open func makeAvailable(view: UIView, insets: UIEdgeInsets, cornerRadius: CGFloat) {
        focus = (TouchArea.view(view: view), MaskArea.rect(insets: insets, cornerRadius: cornerRadius))
    }
    
    open func makeAvailable(rect: CGRect) {
        makeAvailable(rect: rect, insets: UIEdgeInsets.zero, cornerRadius: 0.0)
    }
    
    open func makeAvailable(rect: CGRect, insets: UIEdgeInsets, cornerRadius: CGFloat) {
        focus = (TouchArea.rect(rect: rect), MaskArea.rect(insets: insets, cornerRadius: cornerRadius))
    }
    
    open func makeAvailable(rect: CGRect, radiusInset: CGFloat) {
        focus = (TouchArea.rect(rect: rect), MaskArea.radiusInset(radiusInset: radiusInset))
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        
        for layer in self.layer.sublayers ?? [] {
            if layer.name == "TutorialView.backgroundLayer" {
                layer.removeFromSuperlayer()
            }
        }
        
        let path = UIBezierPath(rect: bounds)

        if let focus = focus {
            var rect: CGRect = {
                switch focus.touch {
                case .rect(rect: let rect):
                    return rect
                case .view(view: let view):
                    return self.convert(view.frame, from: view.superview)
                }
            }()
            
            switch focus.mask {
            case .rect(insets: let insets, cornerRadius: let cornerRadius):
                rect.origin.x -= insets.left
                rect.origin.y -= insets.top
                rect.size.width += insets.left + insets.right
                rect.size.height += insets.top + insets.bottom
                
                path.append(UIBezierPath(roundedRect: rect, cornerRadius: cornerRadius))
            case .radiusInset(radiusInset: let radiusInset):
                let center = CGPoint(x: rect.midX, y: rect.midY)
                let rawDiameter = sqrt(pow(rect.width, 2) + pow(rect.height, 2))
                let diameter = round(rawDiameter) + radiusInset * 2.0
                let radius = round(diameter / 2.0)
                
                let x = center.x - radius
                let y = center.y - radius
                
                let circleRect = CGRect(x: x, y: y, width: diameter, height: diameter)
                path.append(UIBezierPath(roundedRect: circleRect, cornerRadius: radius))
            }
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
        if let focus = focus {
            let bypassRect: CGRect = {
                switch focus.touch {
                case .rect(rect: let rect):
                    return rect
                case .view(view: let view):
                    return self.convert(view.frame, from: view.superview)
                }
            }()
            if bypassRect.contains(point) { return nil }
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
