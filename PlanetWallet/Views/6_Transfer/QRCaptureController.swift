//
//  QRCaptureController.swift
//  PlanetWallet
//
//  Created by grabity on 18/06/2019.
//  Copyright © 2019 grabity. All rights reserved.
//

import UIKit
import AVFoundation

class QRCaptureController: PlanetWalletViewController {
    
    @IBOutlet var preview: UIView!
    
    private var session: AVCaptureSession?
    private var previewLayer: AVCaptureVideoPreviewLayer?
    private var qrCodeFrameView: UIView?
    private let supportedCodeTypes = [AVMetadataObject.ObjectType.qr]

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if session == nil {
            session = AVCaptureSession()
        }
        guard let session = session else { return }
        
        if session.isRunning == false {
            configurateCapture()
        }
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    private func configurateCapture() {
        if session == nil {
            session = AVCaptureSession()
        }
        
        configurateSession()
        configurePreviewLayer()
        configureDetectedQRCodeFrameView()
        
        session?.startRunning()
    }
    
    private func configurateSession() {
        guard let session = session else { return }
        
        let deviceDiscoverySession = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInDualCamera, .builtInWideAngleCamera],
                                                                      mediaType: .video, position: .back)
        do {
            guard let captureDevice = deviceDiscoverySession.devices.first else {
                NSLog("Failed to get the camera device")
                return
            }
            
            let input = try AVCaptureDeviceInput(device: captureDevice)
            session.addInput(input)
            
            let output = AVCaptureMetadataOutput()
            session.addOutput(output)
            
            output.setMetadataObjectsDelegate(self, queue: .main)
            output.metadataObjectTypes = [AVMetadataObject.ObjectType.qr]
        }
        catch {
            NSLog(error.localizedDescription)
            return
        }
    }
    
    private func configurePreviewLayer() {
        guard let session = session else { return }
        previewLayer = AVCaptureVideoPreviewLayer(session: session)
        previewLayer?.videoGravity = .resizeAspectFill
        previewLayer?.frame = view.bounds
        preview.layer.addSublayer(previewLayer!)
    }
    
    private func configureDetectedQRCodeFrameView() {
        qrCodeFrameView = UIView()
        
        if let qrCodeFrameView = qrCodeFrameView {
            qrCodeFrameView.layer.borderColor = UIColor.green.cgColor
            qrCodeFrameView.layer.borderWidth = 2
            view.addSubview(qrCodeFrameView)
            view.bringSubviewToFront(qrCodeFrameView)
        }
    }
    
    private func matches(for regex: String, in text: String) -> [String] {
        
        do {
            let regex = try NSRegularExpression(pattern: regex)
            let nsString = text as NSString
            let results = regex.matches(in: text, range: NSRange(location: 0, length: nsString.length))
            return results.map { nsString.substring(with: $0.range)}
        } catch let error {
            print("invalid regex: \(error.localizedDescription)")
            return []
        }
    }
    
    //MARK: - IBAction
    @IBAction func didTouchedClose(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
}

extension QRCaptureController: AVCaptureMetadataOutputObjectsDelegate {
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        if metadataObjects.count == 0 {
            NSLog("No qr code is detected")
            return
        }
        
        let metaObj = metadataObjects[0] as! AVMetadataMachineReadableCodeObject
        
        if supportedCodeTypes.contains(metaObj.type) {
            
            if metaObj.stringValue != nil {
                
                if let matched = matches(for: "0x[0-9a-fA-F]{40}$", in: metaObj.stringValue!).first {
                    print(matched)
                }
            }
        }
    }
}
