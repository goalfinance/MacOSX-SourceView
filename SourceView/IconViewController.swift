//
//  IconViewController.swift
//  SourceView
//
//  Created by Pan Qingrong on 20/11/2017.
//  Copyright © 2017 Big Nerd Ranch. All rights reserved.
//

import Cocoa

let kReceivedContentNotification = "ReceivedContentNotification"
let ITEM_KEY_ICON = "icon"
let ITEM_KEY_NAME = "name"

class IconViewController: NSViewController {
    @IBOutlet var collectionView:NSCollectionView!
    var icons:NSMutableArray?
    var _url:URL?
    var url:URL?{
        get{
            return _url
        }
        set{
            _url = newValue
             Thread.detachNewThreadSelector(#selector(gatherContents(inObject:)), toTarget: self, with: _url)
        }
    }
    var _baseNode:BaseNode?
    var baseNode:BaseNode?{
        set{
            _baseNode = newValue
            self.gatherContents(inObject: _baseNode as Any)
        }
        get{
            return _baseNode
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureCollectionView()
        collectionView.dataSource = nil
    }
    override func awakeFromNib() {
//        self.addObserver(self,
//                         forKeyPath: "url",
//                         options: [NSKeyValueObservingOptions.new,              NSKeyValueObservingOptions.old],
//                         context: nil)
    }
    
    deinit {
//        self.removeObserver(self, forKeyPath: "url")
    }
    
    private func configureCollectionView(){
        let flowLayout = NSCollectionViewFlowLayout()
        flowLayout.itemSize = NSSize(width:105, height:60)
        
        collectionView.collectionViewLayout = flowLayout
        view.wantsLayer = true
    }
    
    @objc func updateIcons(iconArray:Any){
        self.icons = iconArray as? NSMutableArray
        collectionView.dataSource = self
        collectionView.reloadData()
        NotificationCenter.default.post(name: NSNotification.Name.init(kReceivedContentNotification), object: nil)
    }
    
    @objc func gatherContents(inObject:Any){
        autoreleasepool(invoking: {
            let contentArray = NSMutableArray()
            
            if inObject is BaseNode{
                let shortcuts = self.baseNode?.children
                for node in shortcuts!{
                    let baseNode = (node as! BaseNode)
                    let shortcutsImage = (baseNode.nodeIcon?.copy()) as! NSImage
                    shortcutsImage.size = NSMakeSize(CGFloat(kIconLargeImageSize), CGFloat(kIconLargeImageSize))
                    contentArray.add([ITEM_KEY_ICON:shortcutsImage, ITEM_KEY_NAME:baseNode.nodeTitle])
                }
            }else{
                let url = inObject as? URL
                let urls:[URL] = try! FileManager.default.contentsOfDirectory(at: url!, includingPropertiesForKeys: [], options: FileManager.DirectoryEnumerationOptions.skipsHiddenFiles)
                
                for element in urls{
                    let image = NSWorkspace.shared.icon(forFile: element.path)
                    let values = try! element.resourceValues(forKeys:[URLResourceKey.localizedNameKey])
                    let name = values.localizedName
                    contentArray.add([ITEM_KEY_ICON:image, ITEM_KEY_NAME:name!])
                    
                }
            }
            self.performSelector(onMainThread: #selector(updateIcons(iconArray:)), with: contentArray, waitUntilDone: true)
        })
        
    }
    
//    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
//        Thread.detachNewThreadSelector(#selector(gatherContents(inObject:)), toTarget: self, with: self.url)
//    }
    
}
