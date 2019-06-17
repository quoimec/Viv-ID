//
//  WebController.swift
//  Viv-ID
//
//  Created by Charlie on 17/6/19.
//  Copyright © 2019 UTS. All rights reserved.
//

import Foundation
import UIKit
import WebKit

class WebController: UIViewController {
	
	let webURL: URL
	let webView = WKWebView()
	let webNav = WebNavigator()
	
	init(passedURL: URL) {
		self.webURL = passedURL
		super.init(nibName: nil, bundle: nil)
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		webView.uiDelegate = self
		webView.navigationDelegate = self
		
		webNav.translatesAutoresizingMaskIntoConstraints = false
		webView.translatesAutoresizingMaskIntoConstraints = false
		
		self.view.addSubview(webNav)
		self.view.addSubview(webView)
		
		self.view.addConstraints([
		
			// Web Nav
			NSLayoutConstraint(item: webNav, attribute: .leading, relatedBy: .equal, toItem: self.view, attribute: .leading, multiplier: 1.0, constant: 0),
			NSLayoutConstraint(item: webNav, attribute: .top, relatedBy: .equal, toItem: self.view, attribute: .top, multiplier: 1.0, constant: 0),
			NSLayoutConstraint(item: self.view!, attribute: .trailing, relatedBy: .equal, toItem: webNav, attribute: .trailing, multiplier: 1.0, constant: 0),
			NSLayoutConstraint(item: webNav, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 90),
			
			// Web View
			NSLayoutConstraint(item: webView, attribute: .leading, relatedBy: .equal, toItem: self.view, attribute: .leading, multiplier: 1.0, constant: 0),
			NSLayoutConstraint(item: webView, attribute: .top, relatedBy: .equal, toItem: webNav, attribute: .bottom, multiplier: 1.0, constant: 0),
			NSLayoutConstraint(item: self.view!, attribute: .trailing, relatedBy: .equal, toItem: webView, attribute: .trailing, multiplier: 1.0, constant: 0),
			NSLayoutConstraint(item: self.view!, attribute: .bottom, relatedBy: .equal, toItem: webView, attribute: .bottom, multiplier: 1.0, constant: 0)
		
		])
		
		webNav.webButton.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(closeWeb)))
		
		webView.load(URLRequest(url: webURL))
		
	}
	
	@objc func closeWeb() {
		self.dismiss(animated: true, completion: nil)
	}

}

extension WebController: WKUIDelegate, WKNavigationDelegate {

	func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
		print("NAVIGATION COMPLETE")
	}
	
}
