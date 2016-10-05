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
        return UserDefaults.standard.bool(forKey: UserDefaultsKey.isFirstLogin)
    }
    
    @IBOutlet weak var buttonAdd: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if isFirstLogin {
            setUpWalkThrough()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if isFirstLogin {
            TutorialManager.shared.showTutorial(withIdentifier: "1")
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
        
    }
    
    // MARK: - Target action
    
    @IBAction func resetAction(_ sender: AnyObject) {
        UserDefaults.standard.set(true, forKey: UserDefaultsKey.isFirstLogin)
        TutorialManager.shared.shouldShowTutorial = true
        setUpWalkThrough()
        TutorialManager.shared.showTutorial(withIdentifier: "1")
    }
    
    @IBAction func dismissViewController(_ segue: UIStoryboardSegue) {
        finishTutorial()
    }
    
    @IBAction func backgroundAction(_ sender: AnyObject) {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        label.text = "Background was tapped.\nThis message shouldn't\nshow during tutorial."
        label.textAlignment = .center
        label.textColor = UIColor.red
        
        self.view.addSubview(label)
        self.view.addConstraints([
            NSLayoutConstraint(item: label, attribute: .centerX, relatedBy: .equal, toItem: self.view, attribute: .centerX, multiplier: 1.0, constant: 0.0),
            NSLayoutConstraint(item: label, attribute: .centerY, relatedBy: .equal, toItem: self.view, attribute: .centerY, multiplier: 1.5, constant: 0.0)
            ])
        
        let time: DispatchTime = DispatchTime.now() + Double(Int64(Double(NSEC_PER_SEC) * 1.5)) / Double(NSEC_PER_SEC)
        DispatchQueue.main.asyncAfter(deadline: time) { 
            label.removeFromSuperview()
        }
    }
    
    // MARK: - Tutorial
    
    private func setUpWalkThrough() {
        // 1. Show welcome page with button
        // 2. Focus + button in the middle
        // 3. Modally present a view with text fields. Focus first text field
        // 4. Focus next text field
        // 5. Focus `Done` button on upper-right corner
        // 6. Show finish button
        
        let item1 = TutorialItem(nibName: "Welcome", identifier: "1")
        item1.view.frame = Screen.bounds
        item1.nextAction = {
            TutorialManager.shared.showTutorial(withIdentifier: "2")
        }
        
        let quitButton = item1.view.viewWithTag(-1) as! UIButton
        quitButton.addTarget(self, action: #selector(finishTutorial), for: .touchUpInside)
        
        let view2 = TutorialView(frame: Screen.bounds)
        view2.makeAvailable(view: buttonAdd, radiusInset: 20.0)
        
        let prevButton2 = UIButton(type: .system)
        prevButton2.frame = CGRect(x: 0.0, y: 22.0, width: 100.0, height: 44.0)
        prevButton2.setTitle("Prev", for: .normal)
        prevButton2.setTitleColor(UIColor.white, for: .normal)
        
        view2.addSubview(prevButton2)
        view2.prevButton = prevButton2
        
        let label2 = UILabel()
        label2.translatesAutoresizingMaskIntoConstraints = false
        label2.text = "Tap \"+\" button to add."
        label2.textColor = UIColor.white
        
        view2.addSubview(label2)
        view2.addConstraints([
            NSLayoutConstraint(item: label2, attribute: .centerX, relatedBy: .equal, toItem: view2, attribute: .centerX, multiplier: 1.0, constant: 0.0),
            NSLayoutConstraint(item: label2, attribute: .centerY, relatedBy: .equal, toItem: view2, attribute: .centerY, multiplier: 1.5, constant: 0.0)
            ])
        
        let item2 = TutorialItem(view: view2, identifier: "2")
        item2.prevAction = {
            TutorialManager.shared.showTutorial(withIdentifier: "1")
        }
        
        TutorialManager.shared.register(item: item1)
        TutorialManager.shared.register(item: item2)
    }
    
    @objc private func finishTutorial() {
        UserDefaults.standard.set(false, forKey: UserDefaultsKey.isFirstLogin)
        TutorialManager.shared.shouldShowTutorial = false
        TutorialManager.shared.hideTutorial()
        TutorialManager.shared.deregisterAllItems()

    }
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if isFirstLogin {
            TutorialManager.shared.showTransparentItem()
        }
    }
}

