//
//  HomeController.swift
//  Viv-ID
//
//  Created by Charlie on 11/6/19.
//  Copyright © 2019 UTS. All rights reserved.
//

import Foundation
import UIKit
import CoreML
import Vision
import AVFoundation
import AudioToolbox
import SafariServices

class HomeController: UIViewController {

	let homeView = HomeView()
	let cameraView = CameraView()
	
	var liveRequests = Array<VNRequest>()
	var uploadRequests = Array<VNRequest>()
	
	var liveCapture = false
	var liveResults = LiveResults(minimumCount: 10, historySeconds: 5, accuracyThreshold: 0.5)

	var bufferSize: CGSize = .zero
	let captureSession = AVCaptureSession()
	let captureOutput = AVCaptureVideoDataOutput()
	
	private let captureQueue = DispatchQueue(label: "VideoOutput", qos: .userInitiated, attributes: [], autoreleaseFrequency: .workItem)
	
	init() {
		super.init(nibName: nil, bundle: nil)
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		configureModels()
		
		cameraView.translatesAutoresizingMaskIntoConstraints = false
		homeView.translatesAutoresizingMaskIntoConstraints = false
		
		self.view.addSubview(cameraView)
		self.view.addSubview(homeView)
		
		self.view.addConstraints([
		
			// Camera View
			NSLayoutConstraint(item: cameraView, attribute: .leading, relatedBy: .equal, toItem: self.view, attribute: .leading, multiplier: 1.0, constant: 0),
			NSLayoutConstraint(item: cameraView, attribute: .top, relatedBy: .equal, toItem: self.view, attribute: .top, multiplier: 1.0, constant: 0),
			NSLayoutConstraint(item: self.view!, attribute: .trailing, relatedBy: .equal, toItem: cameraView, attribute: .trailing, multiplier: 1.0, constant: 0),
		
			// Home View
			NSLayoutConstraint(item: homeView, attribute: .leading, relatedBy: .equal, toItem: self.view, attribute: .leading, multiplier: 1.0, constant: 0),
			NSLayoutConstraint(item: homeView, attribute: .top, relatedBy: .equal, toItem: cameraView, attribute: .bottom, multiplier: 1.0, constant: -32),
			NSLayoutConstraint(item: self.view!, attribute: .trailing, relatedBy: .equal, toItem: homeView, attribute: .trailing, multiplier: 1.0, constant: 0),
			NSLayoutConstraint(item: self.view!, attribute: .bottom, relatedBy: .equal, toItem: homeView, attribute: .bottom, multiplier: 1.0, constant: 0)
		
		])
		
		
		let capturePressed = UILongPressGestureRecognizer(target: self, action: #selector(initiateCapture(gestureRecognizer:)))
		capturePressed.minimumPressDuration = 0
		
		homeView.captureButton.addGestureRecognizer(capturePressed)
		homeView.uploadButton.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(initiateUpload)))
		
	}
	
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		
		configureCamera()
		
	}
	
}

extension HomeController: AVCaptureVideoDataOutputSampleBufferDelegate {

	func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
		
		if !liveCapture { return }
		
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }

        let classificationRequest = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, orientation: .up, options: [:])
		
        do {
            try classificationRequest.perform(liveRequests)
        } catch {
            print(error)
        }
		
    }

}

extension HomeController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {

	func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
		
		guard let selectedImage = info[.originalImage] as? UIImage, let convertedImage = selectedImage.cgImage else {
			print("Unable to find image")
			picker.dismiss(animated: true)
			return
		}
		
		cameraView.setImage(passedImage: selectedImage)

		let classificationRequest = VNImageRequestHandler(cgImage: convertedImage, orientation: .up, options: [:])
		
		do {
            try classificationRequest.perform(uploadRequests)
        } catch {
            print(error)
        }
		
		picker.dismiss(animated: true)
		
    }

}

extension HomeController {

	func configureModels() {
	
		guard let liveModel = try? VNCoreMLModel(for: CS_Vivid_1().model) else {
			print("Unable to load Live Model")
			return
		}
		
		guard let uploadModel = try? VNCoreMLModel(for: MM_Vivid2_1().model) else {
			print("Unable to load Upload Model")
			return
		}
	
		let liveRequest = VNCoreMLRequest(model: liveModel, completionHandler: { [weak self] (request, error) in
			
			guard let safe = self else { return }
			
			if !safe.liveCapture { return }
			
			guard let classificationResults = request.results as? Array<VNClassificationObservation> else { return }
			
			safe.liveResults.updateResults(passedClass: classificationResults[0].identifier)
			
			DispatchQueue.main.async {

				if safe.liveResults.thresholdMet() {
					safe.cameraView.topIcon.image = UIImage(named: "Check")
				} else {
					safe.cameraView.topIcon.image = UIImage(named: "Waiting")
				}

			}
			
		})
	
		let uploadRequest = VNCoreMLRequest(model: uploadModel, completionHandler: { [weak self] (request, error) in
			
			guard let safe = self else { return }
			
			guard let classificationResults = request.results as? Array<VNClassificationObservation> else { return }
			
			DispatchQueue.main.async {

				safe.cameraView.topIcon.image = UIImage(named: "Check")
				safe.presentPrediction(passedClass: classificationResults[0].identifier)
				
			}
			
		})
		
		liveRequest.imageCropAndScaleOption = .centerCrop
		uploadRequest.imageCropAndScaleOption = .centerCrop
		
		liveRequests = [liveRequest]
		uploadRequests = [uploadRequest]
		
	}

	func configureCamera() {
	
		guard let videoDevice = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInWideAngleCamera], mediaType: .video, position: .back).devices.first else {
			print("Could not create video device")
			return
		}
		
		guard let videoInput = try? AVCaptureDeviceInput(device: videoDevice) else {
			print("Could not create video input")
			return
		}
		
		captureSession.beginConfiguration()
        captureSession.sessionPreset = .vga640x480
		
		guard captureSession.canAddInput(videoInput), captureSession.canAddOutput(captureOutput) else {
			print("Could not add capture input or output")
			return
		}
		
		captureSession.addInput(videoInput)
		captureSession.addOutput(captureOutput)
		
		captureOutput.alwaysDiscardsLateVideoFrames = true
		captureOutput.setSampleBufferDelegate(self, queue: captureQueue)
		captureOutput.videoSettings = [kCVPixelBufferPixelFormatTypeKey as String: Int(kCVPixelFormatType_420YpCbCr8BiPlanarFullRange)]
		
		let captureConnection = captureOutput.connection(with: .video)
        captureConnection?.isEnabled = true
		
		do {
            try videoDevice.lockForConfiguration()
            let dimensions = CMVideoFormatDescriptionGetDimensions(videoDevice.activeFormat.formatDescription)
            bufferSize.width = CGFloat(dimensions.width)
            bufferSize.height = CGFloat(dimensions.height)
            videoDevice.unlockForConfiguration()
        } catch {
            print(error)
        }
		
        captureSession.commitConfiguration()
	
		let previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
        previewLayer.frame = cameraView.cameraLayer.layer.bounds
        cameraView.cameraLayer.layer.addSublayer(previewLayer)
		
        captureSession.startRunning()
		
	}

	func presentPrediction(passedClass: String) {
	
		print("Present Class: \(passedClass)")
	
		let urlLookup: Dictionary<String, URL> = [
			"Marine Turtles": URL(string: "https://www.vividsydney.com/event/light/marine-turtle")!,
			"Opera House Close": URL(string: "https://www.vividsydney.com/event/light/austral-flora-ballet")!,
			"Opera House Far": URL(string: "https://www.vividsydney.com/event/light/austral-flora-ballet")!,
			"Customs House": URL(string: "https://www.vividsydney.com/event/light/under-harbour")!,
			"Dancing Grass": URL(string: "https://www.vividsydney.com/event/light/dancing-grass")!,
			"Regal Peacock": URL(string: "https://www.vividsydney.com/event/light/regal-peacock")!,
			"Jungle Boogie": URL(string: "https://www.vividsydney.com/event/light/jungle-boogie")!,
			"Bin Chickens": URL(string: "https://www.vividsydney.com/event/light/bin-chickens")!,
			"KA3323": URL(string: "https://www.vividsydney.com/event/light/ka3323")!,
			"Electric Playground": URL(string: "https://www.vividsydney.com/event/light/samsung-electric-playground")!,
			"Harmony": URL(string: "https://www.vividsydney.com/event/light/harmony")!,
			"Triangulum": URL(string: "https://www.vividsydney.com/event/light/triangulum")!
		]

		guard let urlReference = urlLookup[passedClass] else {
			print("Unable to find URL for class: \(passedClass)")
			return
		}
		
		let safariController = SFSafariViewController(url: urlReference)
		
		self.present(safariController, animated: true, completion: nil)
		
	}
	
	@objc func initiateCapture(gestureRecognizer: UIGestureRecognizer) {
	
		cameraView.unsetImage()
	
		switch gestureRecognizer.state {
		
			case .began:
			liveCapture = true
			homeView.captureButton.alpha = 0.7
			AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
			cameraView.topIcon.image = UIImage(named: "Waiting")
			
			case .ended:
			liveCapture = false
			homeView.captureButton.alpha = 1.0
			AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
			cameraView.topIcon.image = nil
			
			guard let identifiedClass = liveResults.classIdentified() else {
				print("No class identified")
				return
			}
			
			liveResults.resetResults()
			
			presentPrediction(passedClass: identifiedClass)
			
			default:
			return
			
		}
	
	}
	
	@objc func initiateUpload() {
	
		let photoPicker = UIImagePickerController()
		photoPicker.delegate = self
		photoPicker.sourceType = .photoLibrary
		
		self.present(photoPicker, animated: true)
	
	}

}
