//
//  IconViewControllerCollectionVIewDataSource.swift
//  SourceView
//
//  Created by Pan Qingrong on 24/11/2017.
//  Copyright © 2017 Big Nerd Ranch. All rights reserved.
//

import Cocoa

let ICON_COLLECTION_VIEW_ITEM = NSStoryboard.SceneIdentifier.init("IconCollectionViewItem")

extension IconViewController:NSCollectionViewDataSource{
    func collectionView(_ collectionView: NSCollectionView, numberOfItemsInSection section: Int) -> Int {
        if let icos = icons{
            return icos.count
        }else{
            return 0
        }
    }
    
    func collectionView(_ collectionView: NSCollectionView, itemForRepresentedObjectAt indexPath: IndexPath) -> NSCollectionViewItem {
        let item = collectionView.makeItem(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "IconCollectionViewItem"), for: indexPath)
        guard let collectionViewItem = item as? IconCollectionViewItem else {return item}
        collectionViewItem.imageView?.image = (icons![indexPath.item] as! NSDictionary).value(forKey: ITEM_KEY_ICON) as? NSImage
        collectionViewItem.textField?.stringValue = (icons![indexPath.item] as! NSDictionary).value(forKey: ITEM_KEY_NAME) as! String
        
        return collectionViewItem
        
    }
    
    
}
