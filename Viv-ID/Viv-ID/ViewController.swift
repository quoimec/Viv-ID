//
//  ViewController.swift
//  Viv-ID
//
//  Created by Charlie on 5/6/19.
//  Copyright © 2019 UTS. All rights reserved.
//

import UIKit
import CoreML
import Vision
import AVFoundation

class ViewController: UIViewController {

	let RNClassifier = try! VNCoreMLModel(for: CW_Vivid_1().model)

	var rootLayer: CALayer! = nil
	private var previewLayer: AVCaptureVideoPreviewLayer! = nil
	
	var bufferSize: CGSize = .zero
	let captureSession = AVCaptureSession()
	let captureOutput = AVCaptureVideoDataOutput()
	
	private let captureQueue = DispatchQueue(label: "VideoOutput", qos: .userInitiated, attributes: [], autoreleaseFrequency: .workItem)

	override func viewDidLoad() {
		super.viewDidLoad()
		
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
        rootLayer = self.view.layer
        previewLayer.frame = rootLayer.bounds
        rootLayer.addSublayer(previewLayer)
		
        captureSession.startRunning()
		
	}

}

extension ViewController: AVCaptureVideoDataOutputSampleBufferDelegate {

	


}

