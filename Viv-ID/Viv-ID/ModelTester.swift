//
//  ModelTester.swift
//  Viv-ID
//
//  Created by Charlie on 15/6/19.
//  Copyright © 2019 UTS. All rights reserved.
//

import Foundation
import UIKit
import CoreML
import Vision

class ModelTester {

	var imageFiles: Array<Dictionary<String, String>> = [
		["image": "TR1", "class": "Triangulum"],
		["image": "TR3", "class": "Triangulum"],
		["image": "TR2", "class": "Triangulum"],
		["image": "TR5", "class": "Triangulum"],
		["image": "TR4", "class": "Triangulum"],
		["image": "OC3", "class": "Opera House Close"],
		["image": "OC2", "class": "Opera House Close"],
		["image": "OC1", "class": "Opera House Close"],
		["image": "OC5", "class": "Opera House Close"],
		["image": "OC4", "class": "Opera House Close"],
		["image": "DG1", "class": "Dancing Grass"],
		["image": "DG2", "class": "Dancing Grass"],
		["image": "DG6", "class": "Dancing Grass"],
		["image": "DG5", "class": "Dancing Grass"],
		["image": "DG4", "class": "Dancing Grass"],
		["image": "JB1", "class": "Jungle Boogie"],
		["image": "JB3", "class": "Jungle Boogie"],
		["image": "JB2", "class": "Jungle Boogie"],
		["image": "JB5", "class": "Jungle Boogie"],
		["image": "JB4", "class": "Jungle Boogie"],
		["image": "OF5", "class": "Opera House Far"],
		["image": "OF4", "class": "Opera House Far"],
		["image": "OF3", "class": "Opera House Far"],
		["image": "OF2", "class": "Opera House Far"],
		["image": "OF1", "class": "Opera House Far"],
		["image": "HA4", "class": "Harmony"],
		["image": "HA5", "class": "Harmony"],
		["image": "HA1", "class": "Harmony"],
		["image": "HA2", "class": "Harmony"],
		["image": "HA3", "class": "Harmony"],
		["image": "KA5", "class": "KA3323"],
		["image": "KA4", "class": "KA3323"],
		["image": "KA1", "class": "KA3323"],
		["image": "KA3", "class": "KA3323"],
		["image": "KA2", "class": "KA3323"],
		["image": "RP4", "class": "Regal Peacock"],
		["image": "RP5", "class": "Regal Peacock"],
		["image": "RP1", "class": "Regal Peacock"],
		["image": "RP2", "class": "Regal Peacock"],
		["image": "RP3", "class": "Regal Peacock"],
		["image": "EP3", "class": "Electric Playground"],
		["image": "EP2", "class": "Electric Playground"],
		["image": "EP1", "class": "Electric Playground"],
		["image": "EP5", "class": "Electric Playground"],
		["image": "EP4", "class": "Electric Playground"],
		["image": "CH2", "class": "Customs House"],
		["image": "CH1", "class": "Customs House"],
		["image": "CH5", "class": "Customs House"],
		["image": "CH4", "class": "Customs House"],
		["image": "CH6", "class": "Customs House"],
		["image": "BC4", "class": "Bin Chickens"],
		["image": "BC5", "class": "Bin Chickens"],
		["image": "BC2", "class": "Bin Chickens"],
		["image": "BC3", "class": "Bin Chickens"],
		["image": "BC1", "class": "Bin Chickens"],
		["image": "MT1", "class": "Marine Turtles"],
		["image": "MT2", "class": "Marine Turtles"],
		["image": "MT3", "class": "Marine Turtles"],
		["image": "MT4", "class": "Marine Turtles"],
		["image": "MT5", "class": "Marine Turtles"]
	]
	
	var testingClass: Dictionary<String, String> = [:]
	var badImages = Array<String>()
	
	let modelObject: VNCoreMLModel
	var modelName: String
	var modelTimer = DispatchTime.now()
	var modelRequests = Array<VNRequest>()
	
	var runningTime: Double = 0.0
	var runningAccuracy: Double = 0.0
	var totalRuns: Int = 0
	
	init(modelName: String, passedModel: VNCoreMLModel) {
		
		self.modelName = modelName
		self.modelObject = passedModel
		
	}
	
	func testModel() {
	
		let requestObject = VNCoreMLRequest(model: self.modelObject, completionHandler: { [weak self] (request, error) in
			
			guard let classificationResults = request.results as? Array<VNClassificationObservation> else { return }
			
			guard let safe = self else { return }
			
			safe.totalRuns += 1
			
			safe.runningTime += Double(DispatchTime.now().uptimeNanoseconds - safe.modelTimer.uptimeNanoseconds) / 1_000_000_000
			
			if classificationResults[0].identifier == safe.testingClass["class"] {
				safe.runningAccuracy += 1
				print("RIGHT: \(safe.testingClass["class"]!) | \(safe.testingClass["image"]!)")
			} else {
				safe.badImages.append(safe.testingClass["image"]!)
				print("WRONG: \(safe.testingClass["class"]!) | \(safe.testingClass["image"]!) -> \(classificationResults[0].identifier)")
			}
			
			if safe.imageFiles.count > 0 {
				safe.nextImage()
			} else {
				safe.assessModel()
			}
			
		})
		
		requestObject.imageCropAndScaleOption = .centerCrop
		
		modelRequests = [requestObject]
		
		nextImage()
	
	}
	
	private func nextImage() {
		
		testingClass = imageFiles.removeFirst()
		
		guard let imageObject = UIImage(named: testingClass["image"]!), let imageCore = imageObject.cgImage else { return }
		
		let classificationRequest = VNImageRequestHandler(cgImage: imageCore, options: [:])
		
//		VNImageRequestHandler(cgImage: , orientation: .up, options: [:])
		
		do {
			modelTimer = DispatchTime.now()
            try classificationRequest.perform(modelRequests)
        } catch {
            print(error)
        }
		
	}

	private func assessModel() {
	
		print("\(modelName) Average Time: \(runningTime / Double(totalRuns)) seconds")
		print("\(modelName) Average Accuracy: \((runningAccuracy / Double(totalRuns)) * 100.0)%")
		print(badImages)
	
	}
	
}
