//
//  ViewController.swift
//  KRWalkThrough
//
//  Created by Joshua Park on 06/02/2016.
//  Copyright (c) 2016 Joshua Park. All rights reserved.
//

import UIKit
import KRWalkThrough

class ViewController: UIViewController {
    var isFirstLogin: Bool {
        return NSUserDefaults.standardUserDefaults().boolForKey(UserDefaultsKey.isFirstLogin)
    }
    
    @IBOutlet weak var buttonAdd: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if isFirstLogin {
            setUpWalkThrough()
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        if isFirstLogin {
            TutorialManager.sharedManager().showTutorialWithIdentifier("1")
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
        
    }
    
    // MARK: - Target action
    
    @IBAction func resetAction(sender: AnyObject) {
        NSUserDefaults.standardUserDefaults().setBool(true, forKey: UserDefaultsKey.isFirstLogin)
        TutorialManager.sharedManager().shouldShowTutorial = true
        setUpWalkThrough()
        TutorialManager.sharedManager().showTutorialWithIdentifier("1")
    }
    
    @IBAction func dismissViewController(segue: UIStoryboardSegue) {
        finishTutorial()
    }
    
    @IBAction func backgroundAction(sender: AnyObject) {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        label.text = "Background was tapped.\nThis message shouldn't\nshow during tutorial."
        label.textAlignment = .Center
        label.textColor = UIColor.redColor()
        
        self.view.addSubview(label)
        self.view.addConstraints([
            NSLayoutConstraint(item: label, attribute: .CenterX, relatedBy: .Equal, toItem: self.view, attribute: .CenterX, multiplier: 1.0, constant: 0.0),
            NSLayoutConstraint(item: label, attribute: .CenterY, relatedBy: .Equal, toItem: self.view, attribute: .CenterY, multiplier: 1.5, constant: 0.0)
            ])
        
        let time = dispatch_time(DISPATCH_TIME_NOW, Int64(Double(NSEC_PER_SEC) * 1.5))
        dispatch_after(time, dispatch_get_main_queue()) {
            label.removeFromSuperview()
        }
    }
    
    // MARK: - Tutorial
    
    private func setUpWalkThrough() {
        let item1 = TutorialItem(nibName: "Welcome", identifier: "1")
        item1.view.frame = Screen.bounds
        item1.nextAction = {
            TutorialManager.sharedManager().showTutorialWithIdentifier("2")
        }
        
        let quitButton = item1.view.viewWithTag(-1) as! UIButton
        quitButton.addTarget(self, action: #selector(finishTutorial), forControlEvents: .TouchUpInside)
        
        let view2 = TutorialView(frame: Screen.bounds)
        view2.makeAvailable(buttonAdd, radiusInset: 20.0)
        view2.animationScale = 1.2
        
        let prevButton2 = UIButton(type: .System)
        prevButton2.frame = CGRectMake(0.0, 22.0, 100.0, 44.0)
        prevButton2.setTitle("Prev", forState: .Normal)
        prevButton2.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        
        view2.addSubview(prevButton2)
        view2.prevButton = prevButton2
        
        let label2 = UILabel()
        label2.translatesAutoresizingMaskIntoConstraints = false
        label2.text = "Tap \"+\" button to add."
        label2.textColor = UIColor.whiteColor()
        
        view2.addSubview(label2)
        view2.addConstraints([
            NSLayoutConstraint(item: label2, attribute: .CenterX, relatedBy: .Equal, toItem: view2, attribute: .CenterX, multiplier: 1.0, constant: 0.0),
            NSLayoutConstraint(item: label2, attribute: .CenterY, relatedBy: .Equal, toItem: view2, attribute: .CenterY, multiplier: 1.5, constant: 0.0)
            ])
        
        let item2 = TutorialItem(view: view2, identifier: "2")
        item2.prevAction = {
            TutorialManager.sharedManager().showTutorialWithIdentifier("1")
        }
        
        TutorialManager.sharedManager().registerItem(item1)
        TutorialManager.sharedManager().registerItem(item2)
    }
    
    @objc private func finishTutorial() {
        NSUserDefaults.standardUserDefaults().setBool(false, forKey: UserDefaultsKey.isFirstLogin)
        TutorialManager.sharedManager().shouldShowTutorial = false
        TutorialManager.sharedManager().hideTutorial()

    }
    
    // MARK: - Navigation
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if isFirstLogin {
            TutorialManager.sharedManager().showTransparentItem()
        }
    }
}

