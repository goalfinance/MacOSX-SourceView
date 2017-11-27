//
//  MyOutlineDataSource.swift
//  SourceView
//
//  Created by Pan Qingrong on 23/11/2017.
//  Copyright © 2017 Big Nerd Ranch. All rights reserved.
//

import Foundation
import Cocoa

let kNodesPBoardType = "com.kinematicsystems.outline.item"

extension MyOutlineViewController:NSOutlineViewDataSource, NSPasteboardItemDataProvider{
    // MARK: NSPasteboardItemDataProvider
    func pasteboard(_ pasteboard: NSPasteboard?, item: NSPasteboardItem, provideDataForType type: NSPasteboard.PasteboardType) {
        let s = "Outline Pasteboard Item"
        item.setString(s, forType: type)
    }

    // MARK: Drag & Drop
    func outlineView(_ outlineView: NSOutlineView, pasteboardWriterForItem item: Any) -> NSPasteboardWriting? {
        let pasteBoardItem:NSPasteboardItem = NSPasteboardItem()
        pasteBoardItem.setDataProvider(self, forTypes: [NSPasteboard.PasteboardType.init(kNodesPBoardType)])
        return pasteBoardItem
    }

    func outlineView(_ outlineView: NSOutlineView, draggingSession session: NSDraggingSession, willBeginAt screenPoint: NSPoint, forItems draggedItems: [Any]) {
        draggedNodes = draggedItems
        session.draggingPasteboard.setData(Data(), forType: NSPasteboard.PasteboardType.init(kNodesPBoardType))
    }

    func outlineView(_ outlineView: NSOutlineView, validateDrop info: NSDraggingInfo, proposedItem item: Any?, proposedChildIndex index: Int) -> NSDragOperation {
        var result:NSDragOperation = NSDragOperation.generic
        if item != nil {
            let proposedNode:BaseNode = ((item as! NSTreeNode).representedObject) as! BaseNode
            if proposedNode.isSpecialGroup{
                if index == -1{
                    result = NSDragOperation()
                }else{
                    result = NSDragOperation.move
                }
                
            }else{
                if index == -1{
                    result = NSDragOperation()
                }else{
                    let draggedNode:BaseNode? = ((draggedNodes?[0] as? NSTreeNode)?.representedObject) as? BaseNode
                    if let dn = draggedNode {
                        if dn === proposedNode || proposedNode.isDescendantOf(nodes: [dn]){
                            result = NSDragOperation()
                        }else{
                            result = NSDragOperation.move
                        }
                    }
                }
            }
        }
        
        return result
    }
    func outlineView(_ outlineView: NSOutlineView, acceptDrop info: NSDraggingInfo, item: Any?, childIndex index: Int) -> Bool {
        var indexPath:IndexPath
        if item != nil{
            let targetItem = item as! NSTreeNode
            indexPath = targetItem.indexPath.appending(index)
        }else{
            if index == -1{
                indexPath = IndexPath.init(index: self.contents.count)
            }else{
                indexPath = IndexPath.init(index: index)
            }
        }
        let pboard:NSPasteboard = info.draggingPasteboard()
        if (pboard.availableType(from: [NSPasteboard.PasteboardType.init(kNodesPBoardType)]) != nil){
            self.handleInternalDrops(pborad: pboard, indexPath: indexPath)
            return true
        }
        return false
    }
    func outlineView(_ outlineView: NSOutlineView, draggingSession session: NSDraggingSession, endedAt screenPoint: NSPoint, operation: NSDragOperation) {
        self.draggedNodes = nil
    }

    func handleInternalDrops(pborad:NSPasteboard, indexPath:IndexPath){
        if self.draggedNodes != nil{
            self.treeController.move((self.draggedNodes as! [NSTreeNode]), to: indexPath)
            var indexPathArray:[IndexPath] = [IndexPath]()
            for node in self.draggedNodes!{
                indexPathArray.append((node as! NSTreeNode).indexPath)
            }
            self.treeController.setSelectionIndexPaths(indexPathArray)
        }
    }


}

