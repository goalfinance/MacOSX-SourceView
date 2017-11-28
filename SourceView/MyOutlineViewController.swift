//
//  MyOutlineViewController.swift
//  SourceView
//
//  Created by Pan Qingrong on 25/11/2017.
//  Copyright © 2017 Big Nerd Ranch. All rights reserved.
//

import Cocoa

let ICON_VIEW_CONTROLLER_IDENTIFIER = NSStoryboard.SceneIdentifier.init(rawValue:
    "IconViewController")
let FILE_VIEW_CONTROLLER_IDENTIFIER = NSStoryboard.SceneIdentifier.init(rawValue: "FileViewController")
let WEB_VIEW_CONTROLLER_IDENTIFIER = NSStoryboard.SceneIdentifier.init(rawValue: "WebViewController")
let CHILD_EDIT_WINDOW_CONTROLLER_IDENTIFIER = NSStoryboard.SceneIdentifier.init(rawValue: "ChildEditWindowController")

let KEY_NAME = "name"
let KEY_URL = "url"
let KEY_SEPARATOR = "separator"
let KEY_GROUP = "group"
let KEY_FOLDER = "folder"
let KEY_ENTRIES = "entries"


class TreeAdditionObj:NSObject{
    var nodeName:String?
    var nodeUrl:URL?
    var selectItsParent:Bool = false
    
    init(withUrl url:URL?, withName name:String?, selectAsParent select:Bool){
        self.nodeUrl = url
        self.nodeName = name
        self.selectItsParent = select
    }
    
}
class MyOutlineViewController:NSViewController{
    @IBOutlet var myOutlineView:NSOutlineView!
    @IBOutlet var treeController:NSTreeController!
    
    var iconViewController:IconViewController?
    var fileViewController:FileViewController?
    var webViewController:WebViewController?
    var childEditWindowController:NSWindowController?
    
    @objc var contents = NSMutableArray()
    var draggedNodes:[Any]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.iconViewController = NSStoryboard.main?.instantiateController(withIdentifier: ICON_VIEW_CONTROLLER_IDENTIFIER) as? IconViewController
        self.iconViewController?.view.translatesAutoresizingMaskIntoConstraints = false
        
        self.fileViewController = NSStoryboard.main?.instantiateController(withIdentifier: FILE_VIEW_CONTROLLER_IDENTIFIER) as? FileViewController
        self.fileViewController?.view.translatesAutoresizingMaskIntoConstraints = false
        
        self.webViewController = NSStoryboard.main?.instantiateController(withIdentifier: WEB_VIEW_CONTROLLER_IDENTIFIER) as? WebViewController
        self.webViewController?.view.translatesAutoresizingMaskIntoConstraints = false
        
        self.childEditWindowController = NSStoryboard.main?.instantiateController(withIdentifier:CHILD_EDIT_WINDOW_CONTROLLER_IDENTIFIER ) as? NSWindowController
        
        self.populateOutlineContents()
        
        self.myOutlineView.enclosingScrollView?.verticalScroller?.floatValue = 0.0
        self.myOutlineView.enclosingScrollView?.contentView.scroll(to: NSMakePoint(CGFloat(0), CGFloat(0)))
        self.myOutlineView.selectionHighlightStyle = NSTableView.SelectionHighlightStyle.sourceList
        
        self.myOutlineView.registerForDraggedTypes([NSPasteboard.PasteboardType.init(kNodesPBoardType)])
        
    }
    
    func selectParentFromSelection(){
        if self.treeController.selectedObjects.count > 0{
            let firstSelectedNode = self.treeController.selectedNodes[0]
            if let parentNode = firstSelectedNode.parent{
                let indexPath = parentNode.indexPath
                self.treeController.setSelectionIndexPath(indexPath)
            }else{
                self.treeController.removeSelectionIndexPaths(self.treeController.selectionIndexPaths)
            }
        }
    }
    
    func addPlacesSection(){
        self.addFolder(withName: BaseNode.placesName)
        self.addChild(url: URL.init(fileURLWithPath: NSHomeDirectory()), withName: "Home", selectItsParent: true)
        let appsDictionary = FileManager.default.urls(for: FileManager.SearchPathDirectory.applicationDirectory, in: FileManager.SearchPathDomainMask.localDomainMask)
        self.addChild(url: appsDictionary[0], withName: nil, selectItsParent: true)
        self.selectParentFromSelection()
    }
    
    
    func addBookmarkSection(){
        self.addFolder(withName: BaseNode.bookmarksName)
        let initData = NSDictionary.init(contentsOf: URL.init(fileURLWithPath: Bundle.main.path(forResource: "Outline", ofType: "dict")!))
        self.addEntries(entries: initData?.value(forKey: KEY_ENTRIES) as! NSArray, discloseParent: true)
        self.selectParentFromSelection()
    }
    
    func populateOutlineContents(){
        self.myOutlineView?.isHidden = true
        self.addPlacesSection()
        self.addBookmarkSection()
        
        self.treeController?.removeSelectionIndexPaths((self.treeController?.selectionIndexPaths)!)
        self.myOutlineView?.isHidden = false
    }
    
    func addFolder(withName folderName:String){
        let treeAddition = TreeAdditionObj(withUrl: nil, withName: folderName, selectAsParent: false)
        self.performAddFolder(treeAddtion: treeAddition)
    }
    
    func addChild(url:URL?, withName name:String?, selectItsParent select:Bool){
        let treeAddtion = TreeAdditionObj(withUrl: url, withName: name, selectAsParent: select)
        self.performAddChild(treeAddtion: treeAddtion)
    }
    
    func addEntries(entries:NSArray, discloseParent:Bool){
        for entry in entries{
            if entry is NSDictionary{
                let e = entry as! NSDictionary
                if let urlString = e.value(forKey: KEY_URL){
                    let url = URL.init(string: urlString as! String)
                    if (e.value(forKey: KEY_SEPARATOR) != nil){
                        self.addChild(url: nil, withName: nil, selectItsParent: true)
                    }else if (e.value(forKey: KEY_FOLDER) != nil){
                        let folderName = e.value(forKey: KEY_FOLDER)
                        self.addChild(url: url, withName: folderName as? String, selectItsParent: true)
                    }else if (e.value(forKey: KEY_URL) != nil){
                        let folderName = e.value(forKey: KEY_FOLDER)
                        self.addChild(url: url, withName: folderName as? String, selectItsParent: true)
                    }else{
                        let folderName = e.value(forKey: KEY_GROUP)
                        self.addFolder(withName: folderName as! String)
                        let childEntries = e.value(forKey: KEY_ENTRIES) as! NSArray
                        self.addEntries(entries: childEntries, discloseParent: false)
                        self.selectParentFromSelection()
                    }
                }
                
            }
        }
        if !discloseParent{
            if self.treeController.selectedObjects.count > 0 {
                let lastSelectedNode = self.treeController.selectedNodes[0]
                self.myOutlineView.collapseItem(lastSelectedNode)
            }
        }
    }
    
    func performAddFolder(treeAddtion:TreeAdditionObj){
        var indexPath:IndexPath?
        if self.treeController?.selectedObjects.count == 0{
            indexPath = IndexPath.init(index: self.contents.count)
        }else{
            indexPath = self.treeController?.selectionIndexPath
            let selectedNode = self.treeController?.selectedObjects[0] as! BaseNode
            if selectedNode.isLeaf{
                self.selectParentFromSelection()
            }else{
                indexPath = indexPath?.appending(selectedNode.children.count)
            }
        }
        let node = ChildNode()
        node.nodeTitle = treeAddtion.nodeName!
        self.treeController.insert(node, atArrangedObjectIndexPath: indexPath!)
    }
    
    func performAddChild(treeAddtion:TreeAdditionObj){
        if self.treeController.selectedObjects.count > 0{
            let selectedNode = self.treeController.selectedObjects[0] as! BaseNode
            if selectedNode.isLeaf{
                self.selectParentFromSelection()
            }
        }
        
        var indexPath:IndexPath?
        if self.treeController.selectedObjects.count > 0{
            indexPath = self.treeController.selectionIndexPath
            let selectedNode = self.treeController.selectedObjects[0] as! BaseNode
            indexPath = indexPath?.appending(selectedNode.children.count)
        }else{
            indexPath = IndexPath.init(index: self.contents.count)
        }
        let node = ChildNode()
        node.url = treeAddtion.nodeUrl
        
        if node.url != nil{
            if let nodeName = treeAddtion.nodeName{
                node.nodeTitle = nodeName
            }else{
                node.nodeTitle = FileManager.default.displayName(atPath: (node.url?.absoluteString)!)
            }
        }
        
        self.treeController.insert(node, atArrangedObjectIndexPath: indexPath!)
        if treeAddtion.selectItsParent{
            self.selectParentFromSelection()
        }
        
    }
    
    @objc func addFolder(notification:Notification){
        self.addFolder(withName: BaseNode.untitledName)
    }
    
    @objc func removeFolder(notification:Notification){
        
    }
    
    func viewControllerForSelection(selectedTreeNodes:[NSTreeNode]) -> NSViewController?{
        return nil
    }
    
}
