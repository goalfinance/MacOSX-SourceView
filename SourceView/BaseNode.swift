//
//  BaseNode.swift
//  SourceView
//
//  Created by Pan Qingrong on 20/11/2017.
//  Copyright © 2017 Big Nerd Ranch. All rights reserved.
//

import Foundation
import Cocoa

let kIconSmallImageSize = 16
let kIconLargeImageSize = 32

class BaseNode:NSObject,NSCoding, NSCopying{
    static var placesName:String{
        return "PLACES"
    }
   
    static var bookmarksName:String{
        return "BOOKMARKS"
    }
    
    static var untitledName:String{
        return "Untitled"
    }
    
    override var description: String{
        return "BaseNode"
    }

    var nodeTitle:String = "BaseNode Untitled"
    
    var nodeIcon:NSImage?{
        var icon:NSImage?
        if self.isLeaf{
            if let url = self.url{
                if self.isLeaf{
                    if self.isBookmark{
                        icon = NSWorkspace.shared.icon(forFileType: NSFileTypeForHFSTypeCode(OSType(kGenericURLIcon)))
                    }else{
                        icon = NSWorkspace.shared.icon(forFile: url.path)
                    }
                }else{
                    icon = NSWorkspace.shared.icon(forFile: url.path)
                }
                
            }
            else{
                
            }
            if let ico = icon{
                ico.size = NSMakeSize(CGFloat(kIconSmallImageSize), CGFloat(kIconSmallImageSize))
            }
        }
        else if !self.isSpecialGroup{
            // it's a folder, use the folderImage as its icon
            icon = NSWorkspace.shared.icon(forFileType: NSFileTypeForHFSTypeCode(OSType(kGenericFolderIcon)))
            if let ico = icon{
                ico.size = NSMakeSize(CGFloat(kIconSmallImageSize), CGFloat(kIconSmallImageSize))
            }
        }
        return icon
        
    }
    @objc var children:NSMutableArray = NSMutableArray.init()
    var url:URL?
    var _isLeaf:Bool = false
    @objc var isLeaf:Bool{
        get{
            return _isLeaf
        }
        set{
            _isLeaf = newValue
            if _isLeaf {
                self.children = NSMutableArray.init(object: self)
            }else{
                self.children = NSMutableArray.init()
            }
        }
    }
    var isBookmark:Bool{
        get{
            if let url = self.url{
                return !url.isFileURL
            }
            return false
        }
    }
    var isDirectory:Bool{
        get{
            var isDir = false
            if let url = self.url{
                isDir = url.hasDirectoryPath
            }
            return isDir
        }
    }
    var isSpecialGroup:Bool{
        get{
            if self.nodeTitle == BaseNode.bookmarksName || self.nodeTitle == BaseNode.placesName{
                return true
            }else{
                return false
            }
        }
    }
    var isSeperator:Bool{
        return self.nodeIcon == nil && self.nodeTitle.isEmpty
        
    }
    var mutableKeys:NSArray?{
        return ["nodeTitle", "isLeaf", "children", "nodeIcon", "url", "isBookmark"]
    }
    var descendants:NSArray?{
        let descendants = NSMutableArray.init()
       
        for node in self.children{
            descendants.add(node)
            let n = node as! BaseNode
            if n.isLeaf == false {
                descendants.addObjects(from: n.descendants as! [Any])
            }
        }
        return descendants;
    }
    var allChildLeafs:NSArray?{
        let childLeafs = NSMutableArray.init()
        
        for node in self.children{
            let n = node as! BaseNode
            if n.isLeaf == true {
                childLeafs.add(node)
            }else{
                childLeafs.addObjects(from: n.allChildLeafs as! [Any])
            }
        }
        
        return childLeafs
    }
    var groupChildren:NSArray?{
        let groupChildren = NSMutableArray.init()
        
        for node in self.children{
            let n = node as! BaseNode
            if n.isLeaf == false{
                groupChildren.add(node)
            }
        }
        
        return groupChildren
    }
    
    required override init() {
        super.init()
        self.isLeaf = false
    }
    
    
    convenience init(isLeaf aIsLeaf:Bool?){
        self.init()
        if let isLeaf = aIsLeaf{
            if isLeaf {
                self.isLeaf = true
            }
        }
    }
    
    func copy(with zone: NSZone? = nil) -> Any {
        let newNode = type(of: self).init()
        if let keys = self.mutableKeys{
            for key in keys{
                newNode.setValue(self.value(forKey: key as! String), forKey: key as! String)
            }
        }
        return newNode
    }
    
    required convenience init?(coder aDecoder: NSCoder) {
        self.init()
        if let keys = self.mutableKeys{
            for key in keys{
                self.setValue(aDecoder.decodeObject(forKey: key as! String), forKey: key as!String)
            }
        }
    }
    
    func encode(with aCoder: NSCoder) {
        if let keys = self.mutableKeys{
            for key in keys{
                aCoder.encode(self.value(forKey: key as! String), forKey: key as! String)
            }
        }
    }
    
    func isDescendantOfOrOneOf(nodes aNodes:NSArray) -> Bool{
        for node in aNodes{
            let n = node as!BaseNode
            if n === self{
                return true
            }
            if !n.isLeaf{
                if self.isDescendantOfOrOneOf(nodes: n.children){
                    return true
                }
            }
        }
        return false
    }
    
    func isDescendantOf(nodes aNodes:NSArray) -> Bool{
        for node in aNodes{
            let n = node as! BaseNode
            if !n.isLeaf{
                if self.isDescendantOfOrOneOf(nodes: n.children){
                    return true
                }
            }
        }
        return false
    }
    
    
    
    
}
