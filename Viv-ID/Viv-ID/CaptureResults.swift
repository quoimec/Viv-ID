//
//  LiveResults.swift
//  Viv-ID
//
//  Created by Charlie on 16/6/19.
//  Copyright © 2019 UTS. All rights reserved.
//

import Foundation

struct LiveResults {
	
	private let minimumCount: Double
	private let maximumHistory: Int
	private let accuracyThreshold: Double
	
	private var liveCount: Double = 0.0
	private var liveHistory: Array<String> = []
	private var liveResults: Dictionary<String, Double> = [
		"Triangulum": 0.0,
		"Opera House Close": 0.0,
		"Dancing Grass": 0.0,
		"Jungle Boogie": 0.0,
		"Opera House Far": 0.0,
		"Harmony": 0.0,
		"KA3323": 0.0,
		"Regal Peacock": 0.0,
		"Electric Playground": 0.0,
		"Customs House": 0.0,
		"Bin Chickens": 0.0,
		"Marine Turtles": 0.0
	]
	
	init(minimumCount: Int, historySeconds: Int, accuracyThreshold: Double) {
		
		self.minimumCount = Double(minimumCount)
		self.maximumHistory = historySeconds * 15 // Taken from ResNet speed test ~= 15 FPS
		self.accuracyThreshold = accuracyThreshold
	
	}
	
	func classIdentified() -> String? {
	
		if liveCount < minimumCount { return nil }
	
		for (eachKey, eachValue) in liveResults {
			
			if eachValue > liveCount * accuracyThreshold { return eachKey }
			
		}
			
		return nil
		
	}
	
	mutating func updateResults(passedClass: String) {
	
		liveCount += 1
		liveHistory.append(passedClass)
		liveResults[passedClass]! += 1
		
		if liveHistory.count >= maximumHistory {
			liveResults[liveHistory.removeFirst()]! -= 1
			liveCount -= 1
		}
		
	}
	
	mutating func resetResults() {
		
		liveCount = 0.0
		liveHistory = []
		liveResults = [
			"Triangulum": 0.0,
			"Opera House Close": 0.0,
			"Dancing Grass": 0.0,
			"Jungle Boogie": 0.0,
			"Opera House Far": 0.0,
			"Harmony": 0.0,
			"KA3323": 0.0,
			"Regal Peacock": 0.0,
			"Electric Playground": 0.0,
			"Customs House": 0.0,
			"Bin Chickens": 0.0,
			"Marine Turtles": 0.0
		]
	
	}

	func dumpClasses() {
	
		print("")
		print("-------")
	
		for (eachKey, eachValue) in liveResults {
			print("\(eachKey): \((eachValue / liveCount) * 100)%")
		}
		
		print("-------")
		print("")
	
	}

}
