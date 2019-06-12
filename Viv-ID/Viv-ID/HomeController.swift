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

class HomeController: UIViewController {

	let homeView = HomeView()
	let cameraView = CameraView()
	
	let vividModel = try! VNCoreMLModel(for: Resnet50().model)
	let vividRequests: Array<VNRequest>
	
	var liveCapture = false

	var rootLayer: CALayer! = nil
	private var previewLayer: AVCaptureVideoPreviewLayer! = nil
	
	var bufferSize: CGSize = .zero
	let captureSession = AVCaptureSession()
	let captureOutput = AVCaptureVideoDataOutput()
	
	private let captureQueue = DispatchQueue(label: "VideoOutput", qos: .userInitiated, attributes: [], autoreleaseFrequency: .workItem)
	
	init() {
		
		let requestObject = VNCoreMLRequest(model: vividModel, completionHandler: { (request, error) in
			print("RC Request")
			
			guard let classificationResults = request.results as? Array<VNClassificationObservation> else { return }
			
			print("\(classificationResults[0].identifier): \(classificationResults[0].confidence )")
			
		})
		
		requestObject.imageCropAndScaleOption = .centerCrop
		
		vividRequests = [requestObject]
		
		super.init(nibName: nil, bundle: nil)
	
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
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

        let imageRequestHandler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, orientation: .up, options: [:])
		
        do {
            try imageRequestHandler.perform(vividRequests)
        } catch {
            print(error)
        }
		
    }

}

extension HomeController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {

	func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String: Any]) {
		
		picker.dismiss(animated: true)
		
        // We always expect `imagePickerController(:didFinishPickingMediaWithInfo:)` to supply the original image.
//        let image = info[UIImagePickerControllerOriginalImage] as! UIImage
//        imageView.image = image
//        updateClassifications(for: image)
    }

}

extension HomeController {

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
	
		previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
        previewLayer.frame = cameraView.cameraLayer.layer.bounds
        cameraView.cameraLayer.layer.addSublayer(previewLayer)
		
        captureSession.startRunning()
		
	}
	
	@objc func initiateCapture(gestureRecognizer: UIGestureRecognizer) {
	
		switch gestureRecognizer.state {
		
			case .began:
			print("Touch Began")
			liveCapture = true
			AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
			
			case .ended:
			print("Touch Ended")
			liveCapture = false
			AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
			
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
