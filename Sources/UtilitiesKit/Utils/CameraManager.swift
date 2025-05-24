//
//  CameraManager.swift
//  UtilitiesKit
//
//  Created by El Mostafa El Ouatri on 20/03/25.
//


import AVFoundation
import Foundation

@MainActor
public class CameraManager: ObservableObject {
    
    @Published public var hasCameraAuthorized = false
    
    public init() {
        hasCameraAuthorized = AVCaptureDevice.authorizationStatus(for: .video) == .authorized
    }
    
    public func requestCameraAccess() async {
        
        let status = AVCaptureDevice.authorizationStatus(for: .video)
        
        switch status {
            case .authorized:
                hasCameraAuthorized = true
            case .notDetermined:
                await AVCaptureDevice.requestAccess(for: .video)
                hasCameraAuthorized = true
            case .denied:
                hasCameraAuthorized = false
            case .restricted:
                hasCameraAuthorized = false
            @unknown default:
                hasCameraAuthorized = false
        }
    }
    
}
