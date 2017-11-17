//
//  TutorialItem.swift
//  KRWalkThrough
//
//  Created by Joshua Park on 17/11/2017.
//

import UIKit

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

