//
//  TutorialView.swift
//  ZwiModule
//
//  Created by Joshua Park on 17/11/2017.
//

import UIKit

private protocol ActionItem {
    var action: (() -> Void)? { get }
}

open class TutorialView: UIView {
    
    private enum TouchArea {
        case view(UIView)
        case rect(CGRect)
    }
    
    private enum MaskArea {
        case rect(insets: UIEdgeInsets, cornerRadius: CGFloat)
        case radiusInset(CGFloat)
    }
    
    private struct Focus: ActionItem {
        let touch: TouchArea
        let mask: MaskArea
        let action: (() -> Void)?
    }
    
    private struct Block: ActionItem {
        let rect: CGRect
        let action: (() -> Void)?
    }
    
    open internal(set) weak var item: TutorialItem!
    
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
    private var actionItemList = [ActionItem]()
    
    open func makeAvailable(view: UIView,
                            action: (() -> Void)? = nil)
    {
        makeAvailable(view: view,
                      insets: UIEdgeInsets.zero,
                      cornerRadius: 0.0,
                      action: action)
    }
    
    open func makeAvailable(view: UIView,
                            insets: UIEdgeInsets,
                            cornerRadius: CGFloat,
                            action: (() -> Void)? = nil)
    {
        let focus = Focus(touch: .view(view),
                          mask: .rect(insets: insets,
                                      cornerRadius: cornerRadius),
                          action: action)
        actionItemList.append(focus)
    }
    
    //: Makes a circle-shaped available area with the given radius inset
    open func makeAvailable(view: UIView,
                            radiusInset: CGFloat,
                            action: (() -> Void)? = nil)
    {
        let focus = Focus(touch: .view(view),
                          mask: .radiusInset(radiusInset),
                          action: action)
        actionItemList.append(focus)
    }
    
    open func makeAvailable(rect: CGRect,
                            action: (() -> Void)? = nil)
    {
        makeAvailable(rect: rect,
                      insets: UIEdgeInsets.zero,
                      cornerRadius: 0.0,
                      action: action)
    }
    
    open func makeAvailable(rect: CGRect,
                            insets: UIEdgeInsets,
                            cornerRadius: CGFloat,
                            action: (() -> Void)? = nil)
    {
        let focus = Focus(touch: .rect(rect),
                          mask: .rect(insets: insets,
                                      cornerRadius: cornerRadius),
                          action: action)
        actionItemList.append(focus)
    }
    
    open func makeAvailable(rect: CGRect,
                            radiusInset: CGFloat,
                            action: (() -> Void)? = nil)
    {
        let focus = Focus(touch: .rect(rect),
                          mask: .radiusInset(radiusInset),
                          action: action)
        actionItemList.append(focus)
    }
    
    open func makeUnavailable(rect: CGRect,
                              action: (() -> Void)? = nil) {
        let block = Block(rect: rect,
                          action: action)
        actionItemList.append(block)
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        
        for layer in self.layer.sublayers ?? [] {
            if layer.name == "TutorialView.backgroundLayer" {
                layer.removeFromSuperlayer()
            }
        }
        
        let path = UIBezierPath(rect: bounds)
        
        for item in actionItemList {
            guard let focus = item as? Focus else { continue }
            
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
        for item in actionItemList {
            if let block = item as? Block {
                if block.rect.contains(point) {
                    block.action?()
                    
                    return super.hitTest(point, with: event)
                }
            } else {
                let focus = item as! Focus
                
                let bypassRect: CGRect = {
                    switch focus.touch {
                    case .rect(rect: let rect):
                        return rect
                    case .view(view: let view):
                        return self.convert(view.frame, from: view.superview)
                    }
                }()
                
                if bypassRect.contains(point) {
                    focus.action?()
                    return nil
                }
            }
        }
        
        return super.hitTest(point, with: event)
    }
        
}

