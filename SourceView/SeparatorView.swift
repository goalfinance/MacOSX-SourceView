//
//  SeparatorView.swift
//  SourceView
//
//  Created by Pan Qingrong on 22/11/2017.
//  Copyright © 2017 Big Nerd Ranch. All rights reserved.
//

import Foundation
import Cocoa

class SeparatorView:NSView{
    override func draw(_ dirtyRect: NSRect) {
        let lineWidth:CGFloat = dirtyRect.size.width - 2
        let lineX:CGFloat = 0
        var lineY:CGFloat = (dirtyRect.size.height - 2) / 2
        lineY += 0.5
        NSColor.init(deviceRed: CGFloat(0.349), green: CGFloat(0.6), blue:CGFloat(0.898), alpha: CGFloat(0.6)).set()
        NSMakeRect(dirtyRect.origin.x + lineX, dirtyRect.origin.y + lineY, lineWidth, CGFloat(1)).fill()
        
        NSColor.init(deviceRed: CGFloat(0.976), green: CGFloat(1.0), blue:CGFloat(1.0), alpha: CGFloat(1.0)).set()
        NSMakeRect(dirtyRect.origin.x + lineX, dirtyRect.origin.y + lineY + 1, lineWidth, CGFloat(1)).fill()
        
    }
}
