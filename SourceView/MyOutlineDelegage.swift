//
//  MyOutlineViewControllerDelegage.swift
//  SourceView
//
//  Created by Pan Qingrong on 23/11/2017.
//  Copyright © 2017 Big Nerd Ranch. All rights reserved.
//

import Foundation
import Cocoa

extension MyOutlineViewController:NSOutlineViewDelegate{
    func outlineView(_ outlineView: NSOutlineView, shouldSelectItem item: Any) -> Bool {
        let treeNode = item as! NSTreeNode
        let node = treeNode.representedObject as! BaseNode
        return (!node.isSpecialGroup) && (!node.isSeperator)
    }
    
    func outlineView(_ outlineView: NSOutlineView, isGroupItem item: Any) -> Bool {
        let treeNode = item as! NSTreeNode
        let node = treeNode.representedObject as! BaseNode
        return node.isSpecialGroup
    }
    
    func outlineView(_ outlineView: NSOutlineView, viewFor tableColumn: NSTableColumn?, item: Any) -> NSView? {
        var tableCellView:NSTableCellView?
        let node = (item as! NSTreeNode).representedObject as! BaseNode
        if self.outlineView(outlineView, isGroupItem: item){
            let identifier = outlineView.tableColumns[0].identifier
            tableCellView = outlineView.makeView(withIdentifier: identifier, owner: self) as? NSTableCellView
            let value = node.nodeTitle
            tableCellView?.textField?.stringValue = value
            tableCellView?.imageView?.image = nil
        }else if node.isSeperator{
            tableCellView = outlineView.makeView(withIdentifier: NSUserInterfaceItemIdentifier.init("Separator"), owner: self) as? NSTableCellView
        }else{
            tableCellView = outlineView.makeView(withIdentifier: (tableColumn?.identifier)!, owner: self) as? NSTableCellView
            tableCellView?.textField?.stringValue = node.nodeTitle
            tableCellView?.imageView?.image = node.nodeIcon
        }
        return tableCellView
        
    }
}
