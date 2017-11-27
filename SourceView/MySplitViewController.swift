//
//  MySplitViewController.swift
//  SourceView
//
//  Created by Pan Qingrong on 18/11/2017.
//  Copyright © 2017 Big Nerd Ranch. All rights reserved.
//

import Cocoa

class MySplitViewController: NSSplitViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear() {
        super.viewDidAppear()
        self.outlineViewController().treeController.addObserver(self, forKeyPath: "selectedObjects", options: NSKeyValueObservingOptions.new, context: nil)
    }
    
    deinit {
        self.outlineViewController().treeController.removeObserver(self, forKeyPath: "selectedObjects")
    }
    
    func outlineViewController() -> MyOutlineViewController{
        let leftSplitViewItem = self.splitViewItems[0]
        return leftSplitViewItem.viewController as! MyOutlineViewController
    }
    
    func detailViewController() -> NSViewController{
        let rightSplitViewItem = self.splitViewItems[1]
        return rightSplitViewItem.viewController
    }
    
    func hasChildViewController() -> Bool{
        return self.detailViewController().childViewControllers.count > 0
    }
    
    func embedChildViewController(childViewController:NSViewController){
        let currentDetailViewController = self.detailViewController()
        currentDetailViewController.addChildViewController(childViewController)
        currentDetailViewController.view.addSubview(childViewController.view)
        let views:[String:Any] = ["targetView":childViewController.view]
        let horizontalConstraints = NSLayoutConstraint.constraints(withVisualFormat: "H:|[targetView]|", options: NSLayoutConstraint.FormatOptions.init(rawValue: 0), metrics: nil, views: views)
        
        let verticalConstraints = NSLayoutConstraint.constraints(withVisualFormat: "V:|[targetView]|", options: NSLayoutConstraint.FormatOptions.init(rawValue: 0), metrics: nil, views: views)
        
        NSLayoutConstraint.activate(horizontalConstraints)
        NSLayoutConstraint.activate(verticalConstraints)
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if object != nil && keyPath != nil && keyPath == "selectedObjects"{
            let currentDetailViewController = self.detailViewController()
            let treeController = object as! NSTreeController
            if let viewControllerForSelection = self.outlineViewController().viewControllerForSelection(selectedTreeNodes: treeController.selectedNodes){
                if self.hasChildViewController(){
                    currentDetailViewController.removeChildViewController(at: 0)
                    currentDetailViewController.view.subviews[0] .removeFromSuperview()
                    self.embedChildViewController(childViewController: viewControllerForSelection)
                }else{
                    self.embedChildViewController(childViewController: viewControllerForSelection)
                }
            }else{
                if self.hasChildViewController(){
                    currentDetailViewController.removeChildViewController(at: 0)
                    currentDetailViewController.view.subviews[0].removeFromSuperview()
                }
            }
        }
    }
    
    
    
}
