//
//  CameraController.swift
//  Pixelate
//
//  Created by Taneja-Mac on 21/08/18.
//  Copyright © 2018 Taneja-Mac. All rights reserved.
//

import UIKit
import Foundation
import AVFoundation
import ImageIO

protocol CameraControllerDelegate {
    func lensAperture() -> Float
    func iso() -> Float
    func exposureDuration() -> CMTime
}

protocol CameraControllerDataSource {
    func switchToAutoMode()
    func switchToManualMode()
    func setISO(_ value: Float)
    func setExposureDuration(_ value: Float)
}


protocol PixelateManualModeDataSource {
    func getMinISO() -> Float
    func getMaxISO() -> Float
    func getMinExposureDuration() -> CMTime
    func getMaxExposureDuration() -> CMTime
}

class CameraController: NSObject {
    
    var captureSession: AVCaptureSession?
    var frontCamera: AVCaptureDevice?
    var rearCamera: AVCaptureDevice?
    var currentCameraPosition: CameraPosition?
    var frontCameraInput: AVCaptureDeviceInput?
    var rearCameraInput: AVCaptureDeviceInput?
    var photoOutput: AVCapturePhotoOutput?
    var previewLayer: AVCaptureVideoPreviewLayer?
    var flashMode:AVCaptureDevice.FlashMode = AVCaptureDevice.FlashMode.auto
    var photoCaptureCompletionBlock: ((UIImage?, ImageConfiguration?, PixelateData?, [String:Any]?, Error?) -> Void)?
    var imageConfig = ImageConfiguration(dictionary: [:])
    var pixelateData: PixelateData?
    public enum CameraPosition {
        case front
        case rear
    }
    
    enum CameraControllerError: Swift.Error {
        case captureSessionAlreadyRunning
        case captureSessionIsMissing
        case inputsAreInvalid
        case invalidOperation
        case noCamerasAvailable
        case unknown
    }
    
    fileprivate func configFrontCamera() {
        let exposure_duration:Double = Double(round(1000 * (self.frontCamera?.exposureDuration.seconds ?? 0.00)) / 1000)
        let iso_speed:Double = (self.frontCamera?.iso ?? 0) > 0 ? Double(self.frontCamera!.iso) : 0.00
        let aperture:Double = ((self.frontCamera?.lensAperture ?? 0) >= 0) ? Double(self.frontCamera!.lensAperture) : 0.00
        self.imageConfig.camera = "front"
        self.imageConfig.aperture = aperture > 0.00 ? "\(aperture)" : "N.A"
        self.imageConfig.color_mode = self.frontCamera?.activeColorSpace == .sRGB ? "RGB" : "DCI-P3"
        self.imageConfig.iso_speed = iso_speed > 0.00 ? "\(iso_speed)" : "N.A"
        self.imageConfig.zoom = self.frontCamera?.videoZoomFactor ?? 0 >= 0 ? "\(self.frontCamera!.videoZoomFactor)" : "N.A"
        self.imageConfig.depth = "1"
        self.imageConfig.exposure_duration = exposure_duration > 0.00 ? "\(exposure_duration)" : "N.A"
        let naturalLog = log(aperture)
        let ev: Double = ((iso_speed / 100) * (naturalLog * naturalLog)) / exposure_duration
        self.imageConfig.ev = ev > 0.00 ? "\(ev)" : "N.A"
    }
    
    fileprivate func configRearCamera() {
        let exposure_duration:Double = Double(round(1000 * (self.rearCamera?.exposureDuration.seconds ?? 0.00)) / 1000)
        let iso_speed:Double = (self.rearCamera?.iso ?? 0) > 0 ? Double(self.rearCamera!.iso) : 0.00
        let aperture:Double = ((self.rearCamera?.lensAperture ?? 0) >= 0) ? Double(self.rearCamera!.lensAperture) : 0.00
        self.imageConfig.camera = "rear"
        self.imageConfig.aperture = aperture > 0.00 ? "\(aperture)" : "N.A"
        self.imageConfig.color_mode = self.rearCamera?.activeColorSpace == .sRGB ? "RGB" : "DCI-P3"
        self.imageConfig.iso_speed = iso_speed > 0.00 ? "\(iso_speed)" : "N.A"
        self.imageConfig.zoom = self.rearCamera?.videoZoomFactor ?? 0 >= 0 ? "\(self.rearCamera!.videoZoomFactor)" : "N.A"
        self.imageConfig.depth = "1"
        self.imageConfig.exposure_duration = "\(exposure_duration)"
        let naturalLog = log(aperture)
        let ev: Double = ((iso_speed / 100) * (naturalLog * naturalLog)) / exposure_duration
        self.imageConfig.ev = ev > 0.00 ? "\(ev)" : "N.A"
    }
    
    func prepare(completionHandler: @escaping (Error?) -> Void) {
        func createCaptureSession() {
            self.captureSession = AVCaptureSession()
        }
        func configureCaptureDevices() throws {
            let session = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInWideAngleCamera], mediaType: .video, position: .unspecified)
            guard let cameras: [AVCaptureDevice] = session.devices.map({ $0 }), !cameras.isEmpty else { throw CameraControllerError.noCamerasAvailable }
            for camera in cameras {
                if camera.position == .front {
                    self.frontCamera = camera
                    self.configFrontCamera()
                }
                
                if camera.position == .back {
                    self.rearCamera = camera
                    self.configRearCamera()
                    try camera.lockForConfiguration()
                    camera.focusMode = .continuousAutoFocus
                    camera.unlockForConfiguration()
                }
            }
        }
        func configureDeviceInputs() throws {
            guard let captureSession = self.captureSession else { throw CameraControllerError.captureSessionIsMissing }
            if let rearCamera = self.rearCamera {
                self.rearCameraInput = try AVCaptureDeviceInput(device: rearCamera)
                
                if captureSession.canAddInput(self.rearCameraInput!) { captureSession.addInput(self.rearCameraInput!) }
                
                self.currentCameraPosition = .rear
            }
            else if let frontCamera = self.frontCamera {
                self.frontCameraInput = try AVCaptureDeviceInput(device: frontCamera)
                
                if captureSession.canAddInput(self.frontCameraInput!) { captureSession.addInput(self.frontCameraInput!) }
                else { throw CameraControllerError.inputsAreInvalid }
                
                self.currentCameraPosition = .front
            }
                
            else { throw CameraControllerError.noCamerasAvailable }

        }
        func configurePhotoOutput() throws {
            guard let captureSession = self.captureSession else { throw CameraControllerError.captureSessionIsMissing }
            self.photoOutput = AVCapturePhotoOutput()
            self.photoOutput!.connection(with: .video)
            self.photoOutput!.setPreparedPhotoSettingsArray([AVCapturePhotoSettings(format: [AVVideoCodecKey : AVVideoCodecType.jpeg])], completionHandler: nil)
            self.photoOutput != nil ? captureSession.canAddOutput(self.photoOutput!) ? captureSession.addOutput(self.photoOutput!) : () : ()
            captureSession.startRunning()
        }
        
        DispatchQueue(label: "prepare").async {
            do {
                createCaptureSession()
                try configureCaptureDevices()
                try configureDeviceInputs()
                try configurePhotoOutput()
            }
                
            catch {
                DispatchQueue.main.async {
                    completionHandler(error)
                }
                
                return
            }
            
            DispatchQueue.main.async {
                completionHandler(nil)
            }
        }
    }
    
    func displayPreview(on view: UIView) throws {
        guard let captureSession = self.captureSession, captureSession.isRunning else { throw CameraControllerError.captureSessionIsMissing }
        self.previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        self.previewLayer?.videoGravity = AVLayerVideoGravity.resizeAspectFill
        self.previewLayer?.connection?.videoOrientation = .portrait
        
        view.layer.insertSublayer(self.previewLayer!, at: 0)
        self.previewLayer?.frame = view.frame
    }
    
    func switchCameras() throws {
        guard let currentCameraPosition = currentCameraPosition, let captureSession = self.captureSession, captureSession.isRunning else { throw CameraControllerError.captureSessionIsMissing }
        captureSession.beginConfiguration()

        func switchToFrontCamera() throws {
            guard let inputs = captureSession.inputs as? [AVCaptureInput], let rearCameraInput = self.rearCameraInput, inputs.contains(rearCameraInput),
                let frontCamera = self.frontCamera else { throw CameraControllerError.invalidOperation }
            
            self.frontCameraInput = try AVCaptureDeviceInput(device: frontCamera)
            
            captureSession.removeInput(rearCameraInput)
            
            if captureSession.canAddInput(self.frontCameraInput!) {
                captureSession.addInput(self.frontCameraInput!)
                self.currentCameraPosition = .front
                self.configFrontCamera()
            }
                
            else { throw CameraControllerError.invalidOperation }
        }
        
        func switchToRearCamera() throws {
            guard let inputs = captureSession.inputs as? [AVCaptureInput], let frontCameraInput = self.frontCameraInput, inputs.contains(frontCameraInput),
                let rearCamera = self.rearCamera else { throw CameraControllerError.invalidOperation }
            
            self.rearCameraInput = try AVCaptureDeviceInput(device: rearCamera)
            
            captureSession.removeInput(frontCameraInput)
            
            if captureSession.canAddInput(self.rearCameraInput!) {
                captureSession.addInput(self.rearCameraInput!)
                self.currentCameraPosition = .rear
                self.configRearCamera()
            }
                
            else { throw CameraControllerError.invalidOperation }
        }

        switch currentCameraPosition {
        case .front:
            try switchToRearCamera()
            
        case .rear:
            try switchToFrontCamera()
        }
        captureSession.commitConfiguration()
    }
    
    func captureImage(completion: @escaping (UIImage?, ImageConfiguration?, PixelateData?, [String:Any]? ,Error?) -> Void) {
        guard let captureSession = captureSession, captureSession.isRunning else { completion(nil, nil,nil, nil, CameraControllerError.captureSessionIsMissing); return }
        let EXIFDictionary = [
            kCGImagePropertyExifDateTimeOriginal as String:Date().description.replacingOccurrences(of: "-", with: ":").split(separator: "+")[0].replacingOccurrences(of: " ", with: ""),
            kCGImagePropertyExifISOSpeed as String:self.iso(),
            kCGImagePropertyExifExposureTime as String: self.exposureDuration().seconds,
            kCGImagePropertyExifApertureValue as String: self.lensAperture(),
            kCGImagePropertyExifFlash as String: self.flashMode.rawValue,
            kCGImagePropertyExifUserComment as String: "Pixelate App"
            ] as [String : Any]
        let GPSDictionary = [
            kCGImagePropertyGPSLongitude as String: 73.204496,
            kCGImagePropertyGPSLatitude as String: 22.298450
        ]
        let settings = AVCapturePhotoSettings()
        settings.metadata = [
            kCGImagePropertyExifDictionary as String: EXIFDictionary,
            kCGImagePropertyGPSDictionary as String: GPSDictionary
         
        ]
        settings.flashMode = self.flashMode
        settings.isHighResolutionPhotoEnabled = true
        self.imageConfig.orientation = "1"
        self.photoOutput?.isHighResolutionCaptureEnabled = true
        self.photoOutput?.capturePhoto(with: settings, delegate: self)
        self.pixelateData = PixelateData(dictionary: [:])
        self.pixelateData?.iso = "\(self.iso())"
        self.photoCaptureCompletionBlock = completion
    }
}

extension CameraController: AVCapturePhotoCaptureDelegate {
    
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        self.imageConfig.pixel = Pixel(dimensions: photo.resolvedSettings.photoDimensions)
        if let error = error { self.photoCaptureCompletionBlock?(nil,nil,nil,nil,error) }
        else if let imageData = photo.fileDataRepresentation(), let image = UIImage(data: imageData) {

            self.photoCaptureCompletionBlock?(image, self.imageConfig, self.pixelateData, photo.metadata as? [String:Any] ,nil) }
        else { self.photoCaptureCompletionBlock?(nil, nil, nil, nil,CameraControllerError.unknown) }
    }
}

extension CameraController: CameraControllerDelegate, CameraControllerDataSource {
//    DataSource
    func switchToAutoMode() {
        let camera = self.currentCameraPosition! == .rear ? self.rearCamera! : self.frontCamera!
        try? camera.lockForConfiguration()
        camera.exposureMode = .autoExpose
        camera.unlockForConfiguration()
    }
    
    func switchToManualMode() {
        let camera = self.currentCameraPosition! == .rear ? self.rearCamera! : self.frontCamera!
        try? camera.lockForConfiguration()
        camera.exposureMode = .custom
        camera.unlockForConfiguration()
    }
    
    func setISO(_ value: Float) {
        let exposureDuration = (self.currentCameraPosition! == .rear ? self.rearCamera : self.frontCamera)!.exposureDuration
        let minISOValue = self.getMinISO()
        let maxISOValue = self.getMaxISO()
        let difference = Float(((maxISOValue - minISOValue) / 10.0))
        let newISO = value <= 10 ? value < 2.0 ?  minISOValue : maxISOValue <= value ? maxISOValue : minISOValue + (difference * value) : value
        print(newISO)
        try? (self.currentCameraPosition! == .rear ? self.rearCamera : self.frontCamera)?.lockForConfiguration()
        (self.currentCameraPosition! == .rear ? self.rearCamera : self.frontCamera)?.setExposureModeCustom(duration: exposureDuration, iso: newISO, completionHandler: nil)
        (self.currentCameraPosition! == .rear ? self.rearCamera : self.frontCamera)?.unlockForConfiguration()
    }
    
    func setExposureDuration(_ value: Float) {
        let iso = (self.currentCameraPosition! == .rear ? self.rearCamera : self.frontCamera)!.iso
        let minExposureDuration = self.getMinExposureDuration()
        let maxExposureDuration = self.getMaxExposureDuration()
        let difference = maxExposureDuration.seconds - minExposureDuration.seconds
        let newExposureSeconds = (minExposureDuration.seconds + (difference * Double(value))) / 10
        let newExposureDuration = CMTime(seconds: newExposureSeconds, preferredTimescale: minExposureDuration.timescale)
        try? (self.currentCameraPosition! == .rear ? self.rearCamera : self.frontCamera)?.lockForConfiguration()
        (self.currentCameraPosition! == .rear ? self.rearCamera : self.frontCamera)?.setExposureModeCustom(duration: newExposureDuration, iso: iso, completionHandler: nil)
        (self.currentCameraPosition! == .rear ? self.rearCamera : self.frontCamera)?.unlockForConfiguration()
    }
    
//    Deletate
    
    func lensAperture() -> Float {
        return self.currentCameraPosition == .rear ? self.rearCamera!.lensAperture : self.frontCamera!.lensAperture
    }
    
    func exposureDuration() -> CMTime {
        return self.currentCameraPosition == .rear ? self.rearCamera!.exposureDuration : self.frontCamera!.exposureDuration
    }
    
    func iso() -> Float {
        return self.currentCameraPosition == .rear ? self.rearCamera!.iso : self.frontCamera!.iso
    }
}

extension CameraController: PixelateManualModeDataSource {
    
    func getMaxExposureDuration() -> CMTime {
        return self.currentCameraPosition == .rear ? self.rearCamera!.activeFormat.maxExposureDuration : self.frontCamera!.activeFormat.maxExposureDuration
    }
    
    func getMinExposureDuration() -> CMTime {
        return self.currentCameraPosition == .rear ? self.rearCamera!.activeFormat.minExposureDuration : self.frontCamera!.activeFormat.minExposureDuration
    }
    
    func getMinISO() -> Float {
        return self.currentCameraPosition == .rear ? self.rearCamera!.activeFormat.minISO : self.frontCamera!.activeFormat.minISO
    }
    
    func getMaxISO() -> Float {
        return self.currentCameraPosition == .rear ? self.rearCamera!.activeFormat.maxISO : self.frontCamera!.activeFormat.maxISO
    }
}
