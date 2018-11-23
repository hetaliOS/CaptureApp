//
//  GalleryViewController.swift
//  Capture
//
//  Created by Hetal Chauhan on 11/20/18.
//  Copyright © 2018 Hetal. All rights reserved.
//

import UIKit

class PreviewCaptureViewController: BaseViewController {
    
    //MARK:- OUTLETS
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var btnClose: UIButton!
    @IBOutlet weak var collectionView: PreviewCollectionView!
    
    //MARK:- PROPERTIES
    var images = [UIImageView]()
    let MAX_PAGE = 2
    let MIN_PAGE = 0
    var currentPage = 0
    var arrCaptureImages : [UIImage] = []
    var selectedImageIndex : Int = 0
    
    
   
    //MARK:- VIEW LIFE CYCLE
    override func viewDidLoad() {
        super.viewDidLoad()
        //Add images to scroll
        //addImagesToScrollView()
        
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        collectionView.arrCapturedImages = arrCaptureImages
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { // change 2 to desired number of seconds
            // Your code with delay
            let rect = self.collectionView.layoutAttributesForItem(at: IndexPath(item: self.selectedImageIndex, section: 0))?.frame
            self.collectionView.scrollRectToVisible(rect!, animated: false)
        }
    }
}
