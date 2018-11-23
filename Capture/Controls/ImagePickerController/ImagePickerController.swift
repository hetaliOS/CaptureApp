//
//  ImagePickerController.swift
//  Capture
//
//  Created by Hetal Chauhan on 11/20/18.
//  Copyright © 2018 Hetal. All rights reserved.
//

import UIKit
import Foundation
import AVFoundation

class ImagePickerController: UIImagePickerController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    //MARK:- PROPERTIES
    public var blockCompletion:((_ isCancelled:Bool,_ pickedImage:UIImage?) -> Void)?
    let AppName = Bundle.main.infoDictionary![kCFBundleNameKey as String] as! String
    
    // MARK: - SHARED MANAGER
    public static let shared = ImagePickerController()
    
    
    //MARK:- SHOW IMAGE PICKER
    /// Display image picker with option
    ///
    /// - Parameters:
    ///   - vc: UiViewController
    ///   - completion: completion from return success and UIImage
    public func showImagePickerFrom(vc:UIViewController,
                                    andCompletion completion:@escaping ((_ isCancelled:Bool,_ pickedImage:UIImage?) -> Void)){
        
        self.blockCompletion = completion
        checkPermissionAndProceedFurther(vc: vc)
    }
    
    
    /// Check photo permission
    ///
    /// - Parameter vc: UIViewController
    private func checkPermissionAndProceedFurther(vc:UIViewController){
        
        let cameraMediaType = AVMediaType.video
        let cameraAuthorizationStatus = AVCaptureDevice.authorizationStatus(for: cameraMediaType)
        
        var strMessage = ""
        switch cameraAuthorizationStatus {
        case .denied:
            strMessage = "image : denied"
        case .authorized:
            strMessage = "image : authorized"
        case .restricted:
            strMessage = "image : restricted"
        case .notDetermined:
            strMessage = "image : notDetermined"
        }
        print("IMAGE PERMISSION : \(strMessage)")
        
        if(cameraAuthorizationStatus == .authorized){
            takePhotoFrom(vc: vc)
        }else{
            
            var shouldAlertForGoToSetting:Bool = false
            if(cameraAuthorizationStatus == .notDetermined){
                AVCaptureDevice.requestAccess(for: cameraMediaType) { granted in
                    if granted {
                        print("Granted access to \(cameraMediaType)")
                        self.takePhotoFrom(vc: vc)
                    } else {
                        print("Denied access to \(cameraMediaType)")
                        shouldAlertForGoToSetting = true
                    }
                }
            }else{
                shouldAlertForGoToSetting = true
            }
            
            if(shouldAlertForGoToSetting){
                showAlertWithTitleFromVC(vc: vc, title: AppName, andMessage: "App needs permission to take photo from your library, go to settings and allow access", buttons: ["Dismiss","Settings"], completion: { [weak self](index) in
                    if(index == 1){
                        if let url = URL(string: UIApplicationOpenSettingsURLString) {
                            
                            if #available(iOS 10.0, *) {
                                UIApplication.shared.open(url, options: [:], completionHandler: nil)
                            } else {
                                UIApplication.shared.openURL(url)
                            }
                        }
                    }
                })
            }
        }
    }
    
    
    /// Retun seelcted image
    ///
    /// - Parameter vc: UIViewController
    private func takePhotoFrom(vc:UIViewController){
        
        if !UIImagePickerController.isCameraDeviceAvailable(UIImagePickerControllerCameraDevice.rear) {
                showAlertWithTitleFromVC(vc: vc, title: AppName, andMessage: "Device is not compatible for the required operation", buttons: ["Dismiss"], completion: { [weak self](index) in
                    if(self?.blockCompletion != nil){
                        self?.blockCompletion!(false, nil)
                    }
                })
                return
        }
        
        self.delegate = self
        self.allowsEditing = true//false
        self.sourceType = .camera
    
        
        if(UIImagePickerController.isSourceTypeAvailable(self.sourceType))
        {
            //            self.perform(#selector(presentImagePicker(vc:)), with: vc, afterDelay: 0.25)
            vc.present(self, animated: true)
            {
            }
        }else{
            showAlertWithTitleFromVC(vc: vc, title: AppName, andMessage: "Device is not compatible for the required operation", buttons: ["Dismiss"], completion: { [weak self](index) in
                if(self?.blockCompletion != nil){
                    self?.blockCompletion!(false, nil)
                }
            })
        }
    }
    
    //MARK:- DELEGATE
    
    /// Default Deleget for return selected image
    ///
    /// - Parameters:
    ///   - picker: picker type
    ///   - info: picking info [string : Any]
    public func imagePickerController(_ picker: UIImagePickerController,
                                      didFinishPickingMediaWithInfo info: [String : Any]) {
        
        let imageKey = picker.allowsEditing ? UIImagePickerControllerEditedImage : UIImagePickerControllerOriginalImage
        if let pickedImage = info[imageKey] as? UIImage {
            
            if(self.blockCompletion != nil){
                self.blockCompletion!(true, pickedImage)
            }
        }else{
            if(self.blockCompletion != nil){
                self.blockCompletion!(false, nil)
            }
        }
        
        dismiss(animated: true) {
        }
    }
    
    public func imagePickerControllerDidCancel(_ picker: UIImagePickerController){
        
        if(self.blockCompletion != nil){
            self.blockCompletion!(false, nil)
        }
        dismiss(animated: true) {
            
        }
    }
}

