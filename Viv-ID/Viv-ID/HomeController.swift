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

	let classOverride: String? = nil

	let homeView = HomeView()
	let cameraView = CameraView()
	
	var liveRequests = Array<VNRequest>()
	var uploadRequests = Array<VNRequest>()
	
	var audioImpaired = false
	var audioPlayer = AVPlayer()
	let audioSpeech = AVSpeechSynthesizer()
	
	var liveCapture = false
	var liveResults = LiveResults(minimumCount: 10, historySeconds: 5, accuracyThreshold: 0.5)

	var bufferSize: CGSize = .zero
	let captureSession = AVCaptureSession()
	let captureOutput = AVCaptureVideoDataOutput()
	
	let impactGenerator = UIImpactFeedbackGenerator(style: .medium)
	let notificationGenerator = UINotificationFeedbackGenerator()
	
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
		cameraView.audioIcon.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(updateAudio)))
		
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
	
		guard let liveModel = try? VNCoreMLModel(for: CS_Vivid().model) else {
			print("Unable to load Live Model")
			return
		}
		
		guard let uploadModel = try? VNCoreMLModel(for: MM_Vivid().model) else {
			print("Unable to load Upload Model")
			return
		}
	
		let liveRequest = VNCoreMLRequest(model: liveModel, completionHandler: { [weak self] (request, error) in
			
			guard let safe = self else { return }
			
			if !safe.liveCapture { return }
			
			guard let classificationResults = request.results as? Array<VNClassificationObservation> else { return }
			
			safe.liveResults.updateResults(passedClass: classificationResults[0].identifier)
			
			DispatchQueue.main.async {

				if let identifiedClass = safe.liveResults.classIdentified() {
					
					if safe.cameraView.topLabel.text == "" && safe.audioImpaired {
					
						safe.audioSpeech.stopSpeaking(at: .immediate)
						let speechUtterance = AVSpeechUtterance(string: "I see \(identifiedClass)")
						safe.audioSpeech.speak(speechUtterance)
					
					}
					
					safe.cameraView.topIcon.image = UIImage(named: "Check")
					safe.cameraView.topLabel.text = safe.classOverride != nil ? safe.classOverride : identifiedClass
					
					
					
				} else {
					safe.cameraView.topIcon.image = UIImage(named: "Waiting")
					safe.cameraView.topLabel.text = ""
				}
				
			}
			
		})
	
		let uploadRequest = VNCoreMLRequest(model: uploadModel, completionHandler: { [weak self] (request, error) in
			
			guard let safe = self else { return }
			
			guard let classificationResults = request.results as? Array<VNClassificationObservation> else { return }
			
			DispatchQueue.main.async {

				safe.cameraView.topIcon.image = UIImage(named: "Check")
				safe.cameraView.topLabel.text = safe.classOverride != nil ? safe.classOverride : classificationResults[0].identifier
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
	
		let useClass = classOverride != nil ? classOverride! : passedClass
		
		let pageURL: Dictionary<String, URL> = [
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
		
		let audioURL: Dictionary<String, URL> = [
			"Dancing Grass": URL(string: "https://www.vividsydney.com/sites/default/files/2019-05/Map%2041%20Dancing%20Grass.mp3")!,
			"Marine Turtles": URL(string: "https://www.vividsydney.com/sites/default/files/2019-05/Map%2019%20Marine%20Turtle.mp3")!,
			"Customs House": URL(string: "https://www.vividsydney.com/sites/default/files/2019-05/Map%2020%20Under%20the%20Harbour_Customs%20House.mp3")!,
			"Regal Peacock": URL(string: "https://www.vividsydney.com/sites/default/files/2019-05/Map%2001%20Regal%20Peacock.mp3")!,
			"Jungle Boogie": URL(string: "https://www.vividsydney.com/sites/default/files/2019-05/Map%2034%20Jungle%20Boogie.mp3")!,
			"Bin Chickens": URL(string: "https://www.vividsydney.com/sites/default/files/2019-05/Map%2022%20Bin%20Chickens.mp3")!,
			"KA3323": URL(string: "https://www.vividsydney.com/sites/default/files/2019-05/Map%2030%20KA3323.mp3")!,
			"Electric Playground": URL(string: "https://www.vividsydney.com/sites/default/files/2019-05/Samsung%20Electric%20Playground_updated.mp3")!,
			"Harmony": URL(string: "https://www.vividsydney.com/sites/default/files/2019-05/Map%2035%20Harmony.mp3")!,
			"Triangulum": URL(string: "https://www.vividsydney.com/sites/default/files/2019-05/Map%2023%20Triangulum.mp3")!
		]
		
		if audioImpaired {
		
			guard let urlReference = audioURL[useClass] else {
				print("Unable to find audio URL for class: \(passedClass)")
				return
			}
			
			let playerItem = AVPlayerItem(asset: AVAsset(url: urlReference))
			audioPlayer.replaceCurrentItem(with: playerItem)
			
			audioPlayer.play()
			
		} else {
		
			guard let urlReference = pageURL[useClass] else {
				print("Unable to find URL for class: \(passedClass)")
				return
			}
			
			let safariController = SFSafariViewController(url: urlReference)
			
			self.present(safariController, animated: true, completion: nil)
		
		}
		
	}
	
	@objc func initiateCapture(gestureRecognizer: UIGestureRecognizer) {
	
		cameraView.unsetImage()
	
		switch gestureRecognizer.state {
		
			case .began:
			liveCapture = true
			homeView.captureButton.alpha = 0.7
			impactGenerator.impactOccurred()
			cameraView.topIcon.image = UIImage(named: "Waiting")
			cameraView.topLabel.text = ""
			
			case .ended:
			liveCapture = false
			homeView.captureButton.alpha = 1.0
			cameraView.topIcon.image = nil
			cameraView.topLabel.text = ""
			
			guard let identifiedClass = liveResults.classIdentified() else {
				print("No class identified")
				liveResults.dumpClasses()
				notificationGenerator.notificationOccurred(.error)
				return
			}
			
			notificationGenerator.notificationOccurred(.success)
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

	@objc func updateAudio() {
	
		audioImpaired = !audioImpaired
		
		audioPlayer.pause()
		audioSpeech.stopSpeaking(at: .immediate)
	
		if audioImpaired {
			cameraView.audioIcon.image = UIImage(named: "SoundOn")
		} else {
			cameraView.audioIcon.image = UIImage(named: "SoundOff")
		}
	
	}

}
