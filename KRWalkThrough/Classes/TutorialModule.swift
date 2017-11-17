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
    
    private(set) var availableAction: (() -> Void)? = nil
    private(set) var unavailableAction: (() -> Void)? = nil
    
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
    
    open func makeAvailable(view: UIView, insets: UIEdgeInsets, cornerRadius: CGFloat) {
        focus = (TouchArea.view(view: view), MaskArea.rect(insets: insets, cornerRadius: cornerRadius))
    }
    
    //: Makes a circle-shaped available area with the given radius inset
    open func makeAvailable(view: UIView, radiusInset: CGFloat) {
        focus = (TouchArea.view(view: view), MaskArea.radiusInset(radiusInset: radiusInset))
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
    
    open func setActionForAvailableArea(_ action: @escaping () -> Void) {
        availableAction = action
    }
    
    open func setActionForUnavailableArea(_ action: @escaping () -> Void) {
        unavailableAction = action
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
    
    open override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        unavailableAction?()
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
            if bypassRect.contains(point) {
                availableAction?()
                return nil
            }
        }
        
        return super.hitTest(point, with: event)
    }
    
    deinit {
        if case TouchArea.view(view: let view)? = focus?.touch {
            print("TutorialView deinitialized. Touch view: \(view)")
        } else {
            print("TutorialView deinited")
        }
    }
}

// ===========================
// MARK: - Tutorial Item
// ===========================

open class TutorialItem: NSObject {
    open let identifier: String
    
    open var prevAction: (() -> Void)?
    open var nextAction: (() -> Void)?
    
    open let view: TutorialView
    
    public init(view: TutorialView, identifier: String) {
        assert(!identifier.isEmpty, "Tutorial view must have a valid identifier.")
        self.view = view
        self.identifier = identifier
        super.init()
        prepareView()
    }
    
    public init(nibName: String, identifier: String) {
        assert(!identifier.isEmpty, "Tutorial view must have a valid identifier.")
        self.view = Bundle.main.loadNibNamed(nibName, owner: nil, options: nil)?[0] as! TutorialView
        self.identifier = identifier
        super.init()
        prepareView()
    }
    
    public init(storyboardName: String, storyboardID: String, identifier: String) {
        assert(!identifier.isEmpty, "Tutorial view must have a valid identifier.")
        let vc = UIStoryboard(name: storyboardName, bundle: nil).instantiateViewController(withIdentifier: storyboardID)
        self.view = vc.view as! TutorialView
        self.identifier = identifier
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
    
    @objc fileprivate func prevButtonAction(_ sender: Any) {
        if let prevAction = prevAction {
            prevAction()
        } else {
            print("ERROR: \(TutorialItem.self) line #\(#line) - \(#function)\n** Reason: No action has been set.")
        }
    }
    
    @objc fileprivate func nextButtonAction(_ sender: Any) {
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
    open static let shared = TutorialManager()
    
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
    
    open func register(item: TutorialItem) {
        items[item.identifier] = item
    }
    
    open func deregister(item: TutorialItem) {
        items[item.identifier] = nil
    }
    
    open func deregisterAllItems() {
        for key in items.keys {
            items[key] = nil
        }
    }
    
    open func performNextAction() {
        currentItem?.nextAction?()
    }
    
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
    
    open func showBlankItem(withAction action: Bool = false) {
        UIApplication.shared.delegate!.window!!.addSubview(blankItem.view)
        UIApplication.shared.delegate!.window!!.setNeedsLayout()
        
        if action { currentItem?.nextAction?() }
        currentItem?.view.removeFromSuperview()
        currentItem = nil
    }
    
    open func showTransparentItem(withAction action: Bool = false) {
        UIApplication.shared.delegate!.window!!.addSubview(transparentItem.view)
        UIApplication.shared.delegate!.window!!.setNeedsLayout()
        
        if action { currentItem?.nextAction?() }
        currentItem?.view.removeFromSuperview()
        currentItem = nil
    }
    
    open func hideTutorial(withAction action: Bool = false) {
        if action { currentItem?.nextAction?() }
        currentItem?.view.removeFromSuperview()
        currentItem = nil
    }
}
