//
//  PrimaryViewController.swift
//  SourceView
//
//  Created by Pan Qingrong on 18/11/2017.
//  Copyright © 2017 Big Nerd Ranch. All rights reserved.
//

import Cocoa

let kAddFolderNotification = "AddFolderNotification"
let kRemoveFolderNotification = "RemoveFolderNotification"
let kAddBookmarkNotification = "AddBookmarkNotification"
let kEditBookmarkNotification = "EditBookmarkNotification"

class PrimaryViewController: NSViewController {

    @IBOutlet weak var progIndicator:NSProgressIndicator!
    @IBOutlet weak var removeButton:NSButton!
    @IBOutlet weak var actionButton:NSPopUpButton!
    @IBOutlet weak var urlField:NSTextField!
    @IBOutlet var editBookmarkMenuItem:NSMenuItem!
    
//    override var nibName: NSNib.Name?{
//        return NSNib.Name.init("PrimaryViewController")
//    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let actionImage = NSImage.init(named: NSImage.Name.actionTemplate){
            actionImage.size = NSMakeSize(10, 10)
            let menuItem = NSMenuItem(title: "", action: nil, keyEquivalent: "")
            if let menu = actionButton.menu {
                menu.insertItem(menuItem, at: 0)
                menu.autoenablesItems = false
            }
            menuItem.image = actionImage
        }
        self.editBookmarkMenuItem.isEnabled = false
        if let cell = self.urlField.cell{
            cell.lineBreakMode = NSParagraphStyle.LineBreakMode.byTruncatingMiddle
        }
    }
    
    override func viewWillAppear() {
        super.viewWillAppear()
        NotificationCenter.default.addObserver(self, selector: #selector(outlineViewSelectionDidChange(notification:)), name: NSOutlineView.selectionDidChangeNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(contentReceived(notification:)), name: NSNotification.Name.init(kReceivedContentNotification), object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name:
            NSOutlineView.selectionDidChangeNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.init(kReceivedContentNotification), object: nil)
    }
    
    @objc func contentReceived(notification:NotificationCenter){
        self.progIndicator.isHidden = true
        self.progIndicator.stopAnimation(self)
    }
    
    @objc func outlineViewSelectionDidChange(notification:NSNotification){
        if notification.object != nil{
            let outlineView = notification.object as! NSOutlineView
            let selectedRow = outlineView.selectedRow
            if selectedRow == -1{
                self.removeButton.isEnabled = false
                self.urlField.stringValue = ""
                self.editBookmarkMenuItem.isEnabled = false
            }else{
                self.removeButton.isEnabled = true
                if let selectedTreeNode = outlineView.item(atRow: selectedRow){
                    if let nodeAny = (selectedTreeNode as! NSTreeNode).representedObject{
                        let node:BaseNode = nodeAny as! BaseNode
            
                        if node.isBookmark{
                            if node.url == nil {
                                self.urlField.stringValue = ""
                            }else{
                                self.urlField.stringValue = (node.url?.absoluteString)!
                            }
                        }else{
                            if node.url == nil{
                                self.urlField.stringValue = ""
                            }else{
                                self.urlField.stringValue = (node.url?.path)!
                            }
                        }
                        
                        self.editBookmarkMenuItem.isEnabled = node.isBookmark
                        if node.isDirectory{
                            self.progIndicator.isHidden = false
                        }
                    }
                }
            }
        }
    }
    
    @IBAction func addFolderAction(sender:NSButton){
        NotificationCenter.default.post(name: NSNotification.Name.init(kAddFolderNotification), object: nil)
    }
    
    @IBAction func removeFolderAction(sender:NSButton){
        let alert:NSAlert = NSAlert()
        alert.messageText = NSLocalizedString("Are you sure that you want to remove this item?", comment: "")
        alert.addButton(withTitle: NSLocalizedString("OK", comment: ""))
        alert.addButton(withTitle: NSLocalizedString("Cancel", comment: ""))
        alert.beginSheetModal(for: self.view.window!, completionHandler: {(modelResponse:NSApplication.ModalResponse) in
            if modelResponse == NSApplication.ModalResponse.alertFirstButtonReturn{
                NotificationCenter.default.post(name: NSNotification.Name.init(kRemoveFolderNotification), object: nil)
            }
        })
    }
    
    @IBAction func addBookmarkAction(sender:NSMenuItem){
        NotificationCenter.default.post(name: NSNotification.Name.init(kAddBookmarkNotification), object: nil)
    }
    
    @IBAction func editBookmarkAction(sender:NSMenuItem){
        NotificationCenter.default.post(name: NSNotification.Name.init(kEditBookmarkNotification), object: nil)
    }
    
}
