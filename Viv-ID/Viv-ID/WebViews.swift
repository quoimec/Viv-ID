//
//  WebViews.swift
//  Viv-ID
//
//  Created by Charlie on 17/6/19.
//  Copyright © 2019 UTS. All rights reserved.
//

import Foundation
import UIKit

class WebNavigator: UIView {

	let webHeader = UILabel()
	let webButton = UIView()
	let webDone = UILabel()
	
	init() {
		super.init(frame: CGRect.zero)
	
		self.backgroundColor = UIColor.white
		
		webHeader.font = UIFont.systemFont(ofSize: 22, weight: .heavy)
		webDone.font = UIFont.systemFont(ofSize: 18, weight: .bold)
		webDone.textColor = #colorLiteral(red: 0.14, green: 0.46, blue: 0.90, alpha: 1.00)
		webDone.textAlignment = .center
		webHeader.textAlignment = .center
		
		webHeader.text = "Vivid Sydney"
		webDone.text = "Done"
		
		webDone.translatesAutoresizingMaskIntoConstraints = false
		webHeader.translatesAutoresizingMaskIntoConstraints = false
		webButton.translatesAutoresizingMaskIntoConstraints = false
		
		webButton.addSubview(webDone)
		self.addSubview(webButton)
		self.addSubview(webHeader)
		
		webButton.addConstraints([
			
			// Web Done
			NSLayoutConstraint(item: webDone, attribute: .leading, relatedBy: .equal, toItem: webButton, attribute: .leading, multiplier: 1.0, constant: 0),
			NSLayoutConstraint(item: webButton, attribute: .trailing, relatedBy: .equal, toItem: webDone, attribute: .trailing, multiplier: 1.0, constant: 0),
			NSLayoutConstraint(item: webDone, attribute: .centerY, relatedBy: .equal, toItem: webButton, attribute: .centerY, multiplier: 1.0, constant: 0),
		
		])
		
		self.addConstraints([
		
			// Web Button
			NSLayoutConstraint(item: webButton, attribute: .leading, relatedBy: .equal, toItem: self, attribute: .leading, multiplier: 1.0, constant: 0),
			NSLayoutConstraint(item: self, attribute: .bottom, relatedBy: .equal, toItem: webButton, attribute: .bottom, multiplier: 1.0, constant: 0),
			NSLayoutConstraint(item: webButton, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 100),
			NSLayoutConstraint(item: webButton, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 50),
			
			// Web Header
			NSLayoutConstraint(item: webHeader, attribute: .centerX, relatedBy: .equal, toItem: self, attribute: .centerX, multiplier: 1.0, constant: 0),
			NSLayoutConstraint(item: webHeader, attribute: .centerY, relatedBy: .equal, toItem: webButton, attribute: .centerY, multiplier: 1.0, constant: 0)
		
		])
	
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
}
