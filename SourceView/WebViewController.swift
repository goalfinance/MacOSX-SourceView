//
//  WebViewController.swift
//  SourceView
//
//  Created by Pan Qingrong on 20/11/2017.
//  Copyright © 2017 Big Nerd Ranch. All rights reserved.
//

import Cocoa
import WebKit

class WebViewController: NSViewController,WebResourceLoadDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
    }
    
    func webView(_ sender: WebView!, resource identifier: Any!, didFailLoadingWithError error: Error!, from dataSource: WebDataSource!) {
        if let resourceLoadingError = error as NSError!{
            if let page = resourceLoadingError.userInfo[NSURLErrorFailingURLErrorKey]{
                let errorContent = "<!DOCTYPE html><html><body><head></head><center><br><br><font color=red>Error: unable to load page:<br>\(page)</font></center></body></html>"
                sender.mainFrame.loadHTMLString(errorContent, baseURL: Bundle.main.bundleURL)
            }
        }
    }
    
}
