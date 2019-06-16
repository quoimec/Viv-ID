//
//  HomeViews.swift
//  Viv-ID
//
//  Created by Charlie on 11/6/19.
//  Copyright © 2019 UTS. All rights reserved.
//

import Foundation
import UIKit

class HomeView: UIView {

	let homeHeader = UILabel()
	let captureButton = ButtonView(buttonText: "Live Capture", buttonImage: "Capture", buttonColour: #colorLiteral(red: 0.84, green: 0.11, blue: 0.49, alpha: 1.00))
	let uploadButton = ButtonView(buttonText: "Upload Image", buttonImage: "Photo", buttonColour: #colorLiteral(red: 0.10, green: 0.65, blue: 0.78, alpha: 1.00))
	
	init() {
		super.init(frame: CGRect.zero)
		
		self.backgroundColor = UIColor.white
		self.layer.cornerRadius = 32
		self.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
		
		homeHeader.text = "Viv-ID"
		homeHeader.textColor = UIColor.black
		homeHeader.font = UIFont.init(name: ".SFUIDisplay-BlackItalic", size: 24)
		
		homeHeader.translatesAutoresizingMaskIntoConstraints = false
		captureButton.translatesAutoresizingMaskIntoConstraints = false
		uploadButton.translatesAutoresizingMaskIntoConstraints = false
	
		self.addSubview(homeHeader)
		self.addSubview(captureButton)
		self.addSubview(uploadButton)
		
		self.addConstraints([
		
			// Home Header
			NSLayoutConstraint(item: homeHeader, attribute: .leading, relatedBy: .equal, toItem: self, attribute: .leading, multiplier: 1.0, constant: 20),
			NSLayoutConstraint(item: homeHeader, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1.0, constant: 24),
			NSLayoutConstraint(item: self, attribute: .trailing, relatedBy: .equal, toItem: homeHeader, attribute: .trailing, multiplier: 1.0, constant: 20),
			
			// Capture Button
			NSLayoutConstraint(item: captureButton, attribute: .leading, relatedBy: .equal, toItem: self, attribute: .leading, multiplier: 1.0, constant: 24),
			NSLayoutConstraint(item: captureButton, attribute: .top, relatedBy: .equal, toItem: homeHeader, attribute: .bottom, multiplier: 1.0, constant: 24),
			NSLayoutConstraint(item: self, attribute: .trailing, relatedBy: .equal, toItem: captureButton, attribute: .trailing, multiplier: 1.0, constant: 24),
			
			// Upload Button
			NSLayoutConstraint(item: uploadButton, attribute: .leading, relatedBy: .equal, toItem: self, attribute: .leading, multiplier: 1.0, constant: 24),
			NSLayoutConstraint(item: uploadButton, attribute: .top, relatedBy: .equal, toItem: captureButton, attribute: .bottom, multiplier: 1.0, constant: 14),
			NSLayoutConstraint(item: self, attribute: .trailing, relatedBy: .equal, toItem: uploadButton, attribute: .trailing, multiplier: 1.0, constant: 24),
			NSLayoutConstraint(item: self, attribute: .bottom, relatedBy: .equal, toItem: uploadButton, attribute: .bottom, multiplier: 1.0, constant: 40)
		
		])
	
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	

}

class ButtonView: UIView {

	let buttonIcon = UIImageView()
	let buttonLabel = UILabel()
	
	init(buttonText: String, buttonImage: String, buttonColour: UIColor) {
		super.init(frame: CGRect.zero)
	
		self.backgroundColor = buttonColour
		self.layer.cornerRadius = 20
		
		buttonIcon.image = UIImage(named: buttonImage)
		buttonIcon.alpha = 0.7
		
		buttonLabel.text = buttonText
		buttonLabel.textColor = UIColor.white
		buttonLabel.font = UIFont.systemFont(ofSize: 18, weight: .heavy)
		buttonLabel.numberOfLines = 0
		
		buttonIcon.translatesAutoresizingMaskIntoConstraints = false
		buttonLabel.translatesAutoresizingMaskIntoConstraints = false
		
		self.addSubview(buttonIcon)
		self.addSubview(buttonLabel)
		
		self.addConstraints([
		
			// Button Icon
			NSLayoutConstraint(item: buttonIcon, attribute: .leading, relatedBy: .equal, toItem: self, attribute: .leading, multiplier: 1.0, constant: 16),
			NSLayoutConstraint(item: buttonIcon, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 1.0, constant: 0),
			NSLayoutConstraint(item: buttonIcon, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 14),
			NSLayoutConstraint(item: buttonIcon, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 14),
			
			// Button Text
			NSLayoutConstraint(item: buttonLabel, attribute: .leading, relatedBy: .equal, toItem: buttonIcon, attribute: .trailing, multiplier: 1.0, constant: 14),
			NSLayoutConstraint(item: buttonLabel, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1.0, constant: 14),
			NSLayoutConstraint(item: self, attribute: .trailing, relatedBy: .equal, toItem: buttonLabel, attribute: .trailing, multiplier: 1.0, constant: 14),
			NSLayoutConstraint(item: self, attribute: .bottom, relatedBy: .equal, toItem: buttonLabel, attribute: .bottom, multiplier: 1.0, constant: 14)
		
		])
	
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
}

class CameraView: UIView {

	let topIcon = UIImageView()
	let topOverlay = UIView()
	let bottomOverlay = UIView()
	let middleView = UIImageView()
	let cameraLayer = UIView()
	
	init() {
		super.init(frame: CGRect.zero)
	
		topOverlay.backgroundColor = UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.5)
		bottomOverlay.backgroundColor = UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.5)
		
		middleView.clipsToBounds = true
		middleView.contentMode = .scaleAspectFill
		
		topIcon.translatesAutoresizingMaskIntoConstraints = false
		cameraLayer.translatesAutoresizingMaskIntoConstraints = false
		middleView.translatesAutoresizingMaskIntoConstraints = false
		topOverlay.translatesAutoresizingMaskIntoConstraints = false
		bottomOverlay.translatesAutoresizingMaskIntoConstraints = false
		
		topOverlay.addSubview(topIcon)
		self.addSubview(cameraLayer)
		self.addSubview(middleView)
		self.addSubview(topOverlay)
		self.addSubview(bottomOverlay)
		
		topOverlay.addConstraints([
		
			// Top Icon
			NSLayoutConstraint(item: topIcon, attribute: .leading, relatedBy: .equal, toItem: topOverlay, attribute: .leading, multiplier: 1.0, constant: 20),
			NSLayoutConstraint(item: topOverlay, attribute: .bottom, relatedBy: .equal, toItem: topIcon, attribute: .bottom, multiplier: 1.0, constant: 12),
			NSLayoutConstraint(item: topIcon, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 24),
			NSLayoutConstraint(item: topIcon, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 24)
		
		])
		
		self.addConstraints([
		
			// Camera Layer
			NSLayoutConstraint(item: cameraLayer, attribute: .leading, relatedBy: .equal, toItem: self, attribute: .leading, multiplier: 1.0, constant: 0),
			NSLayoutConstraint(item: cameraLayer, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1.0, constant: 0),
			NSLayoutConstraint(item: self, attribute: .trailing, relatedBy: .equal, toItem: cameraLayer, attribute: .trailing, multiplier: 1.0, constant: 0),
			NSLayoutConstraint(item: self, attribute: .bottom, relatedBy: .equal, toItem: cameraLayer, attribute: .bottom, multiplier: 1.0, constant: 0),
		
			// Middle View
			NSLayoutConstraint(item: middleView, attribute: .width, relatedBy: .equal, toItem: self, attribute: .width, multiplier: 1.0, constant: 0),
			NSLayoutConstraint(item: middleView, attribute: .height, relatedBy: .equal, toItem: middleView, attribute: .width, multiplier: 1.0, constant: 0),
			NSLayoutConstraint(item: middleView, attribute: .centerX, relatedBy: .equal, toItem: self, attribute: .centerX, multiplier: 1.0, constant: 0),
			NSLayoutConstraint(item: middleView, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 1.0, constant: 0),
			
			// Top Overlay
			NSLayoutConstraint(item: topOverlay, attribute: .leading, relatedBy: .equal, toItem: self, attribute: .leading, multiplier: 1.0, constant: 0),
			NSLayoutConstraint(item: topOverlay, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1.0, constant: 0),
			NSLayoutConstraint(item: self, attribute: .trailing, relatedBy: .equal, toItem: topOverlay, attribute: .trailing, multiplier: 1.0, constant: 0),
			NSLayoutConstraint(item: middleView, attribute: .top, relatedBy: .equal, toItem: topOverlay, attribute: .bottom, multiplier: 1.0, constant: 0),
			
			// Bottom Overlay
			NSLayoutConstraint(item: bottomOverlay, attribute: .leading, relatedBy: .equal, toItem: self, attribute: .leading, multiplier: 1.0, constant: 0),
			NSLayoutConstraint(item: bottomOverlay, attribute: .top, relatedBy: .equal, toItem: middleView, attribute: .bottom, multiplier: 1.0, constant: 0),
			NSLayoutConstraint(item: self, attribute: .trailing, relatedBy: .equal, toItem: bottomOverlay, attribute: .trailing, multiplier: 1.0, constant: 0),
			NSLayoutConstraint(item: self, attribute: .bottom, relatedBy: .equal, toItem: bottomOverlay, attribute: .bottom, multiplier: 1.0, constant: 0)
		
		])
	
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	func setImage(passedImage: UIImage) {
		
		middleView.image = passedImage
		topOverlay.backgroundColor = UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 1.0)
		bottomOverlay.backgroundColor = UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 1.0)
	
	}
	
	func unsetImage() {
	
		middleView.image = nil
		topOverlay.backgroundColor = UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.5)
		bottomOverlay.backgroundColor = UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.5)
		
	}
	
}
