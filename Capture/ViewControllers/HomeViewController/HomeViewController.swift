//
//  HomeViewController.swift
//  Capture
//
//  Created by Hetal Chauhan on 11/20/18.
//  Copyright © 2018 Hetal. All rights reserved.
//

import UIKit

class HomeViewController: BaseViewController {
    
    //MAR:- OUTLET
    @IBOutlet weak var collectionView: HomeCollectionview!
    
    //MARK:- PROPERTIES
    var arrImages : [UIImage] = []
    var arrCapturedImages: [CaptureModel] = []
    
    //MARK:- VIEW LIFE CYCLE
    override func viewDidLoad() {
        super.viewDidLoad()
        //Collection view block
        collectionViewBlock()
        
        //Set right bar button
        setRightBarButton()
        
        //Get capture photos
        getAllCapturedPhotos()
        
        collectionView.isSearchCollection = false
        // Do any additional setup after loading the view.
    }
    override func backButtonTapHandler(sender: UIButton) {
        self.capturePhoto()
    }
    //MARK:- SET RIGHT BAR BUTTON
    func setRightBarButton(){
        self.setRightBarButtons(rightBarButtons: .search) { (sender) in
            let vc = SearchCaptureViewController.loadController()
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    //MARK:- CAPTURE PHOTO
    func capturePhoto(){
        
        //Open image picker
        ImagePickerController.shared.showImagePickerFrom(vc: self, andCompletion: { (isSuccess, image) in
            if isSuccess{
                self.arrImages.append(image!)
                if let imageBase64Str = (image?.convertToBase64String()){
                    let captureModel = CaptureModel()
                    captureModel.imageBase64 = imageBase64Str
                    self.collectionView.arrCapturedImages = self.arrImages.reversed()
                    self.collectionView.reloadData()
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                        self.imageDetectionApiFor(capture: captureModel)
                    }
                }
            }
        })
    }
    
    //MARK:- COLLECTION BLOCK
    func collectionViewBlock(){
        
        //Collectionview selected cell
        collectionView.blockSelectedItemCollection = {[weak self](indexPath)in
            let vc = PreviewCaptureViewController.loadController()
            vc.selectedImageIndex = indexPath.row
            vc.arrCaptureImages = self!.collectionView.arrCapturedImages
            let navViewController: UINavigationController = UINavigationController(rootViewController: vc)
            self!.present(navViewController, animated: true, completion: nil)
        }
        //If no photos are avilable direct take photo from placeholder
        collectionView.blockForTakeCapture = {[weak self]in
            self?.capturePhoto()
        }
        
    }
    //MARK:- GET ALL CAPTURE PHOTO
    func getAllCapturedPhotos() {
        arrCapturedImages =  CaptureDatabaseManager.shared.getCapturedImages()
        guard arrCapturedImages.count == 0 else{
            
            // Get all captured images from model as image
            arrImages = arrCapturedImages.map{$0.imageBase64.convertToImage()}
            collectionView.arrCapturedImages = arrImages.reversed()
            collectionView.reloadData()
            return
        }
    }
    //MARK:- API
    //MARK:- Image Detection Api
    func imageDetectionApiFor(capture: CaptureModel){
        if !RechabilityManager.shared.isInternetAvailableForAllNetworks(){
            CaptureDatabaseManager.shared.addCaptureImage(captureModel: capture)
            arrCapturedImages.append(capture)

        }else{
            Service.imageDetection(model: capture) { (isSuccess, message, arrTag) in
                if isSuccess{
                     let captureModel = capture
                     captureModel.tag = (arrTag?.joined(separator: ","))!
                     captureModel.isSyncedToServer = true
                    self.arrCapturedImages.append(captureModel)
                     CaptureDatabaseManager.shared.addCaptureImage(captureModel: capture)
                }else{
                  showAlertWithTitleFromVC(vc: self, title: "", andMessage: "Something went wrong.", buttons: ["Ok"], completion: nil)
                }
            }
        }
    }
}
