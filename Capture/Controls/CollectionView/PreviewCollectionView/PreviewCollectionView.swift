//
//  PreviewCollectionView.swift
//  Capture
//
//  Created by Hetal Chauhan on 11/22/18.
//  Copyright © 2018 Hetal. All rights reserved.
//

import UIKit

class PreviewCollectionView: UICollectionView {
    
    let cellIdentifier = "PreviewCollectionViewCell"
    
    // MARK:- PROPERTIES
    private let marginVertical:CGFloat =  0
    private let marginHorizontal:CGFloat = 0

    var arrCapturedImages: [UIImage] = []
    var width : CGFloat = 0.0
    var height: CGFloat = 0.0
    // MARK:- BLOCKS
    var blockSelectedItemCollection:((_ indexPath: IndexPath)->Void)?
    var blockForTakeCapture:(()->Void)?
    // MARK:- INIT
    override func awakeFromNib() {
        super.awakeFromNib()
        self.doSetupCollectionView()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        width = self.frame.width
        height = self.frame.height
    }
    
    
    // MARK:- SETUP COLLECTIONVIEW
    
    func doSetupCollectionView() {
        self.register(UINib(nibName: cellIdentifier, bundle: nil), forCellWithReuseIdentifier: cellIdentifier)
        
        let flowLayout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        flowLayout.scrollDirection = .horizontal
        self.alwaysBounceVertical = false;
         self.alwaysBounceHorizontal = false;
        self.collectionViewLayout = flowLayout
        self.contentInset = UIEdgeInsetsMake(0 , 0, 0, 0)
        self.allowsMultipleSelection = true
        self.delegate = self
        self.dataSource = self
        self.isPagingEnabled = true
    }
}
extension PreviewCollectionView: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout{
    
    // MARK:- UICOLLECTIONVIEW DATASOURCE
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return arrCapturedImages.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellIdentifier, for: indexPath)  as! PreviewCollectionViewCell
        cell.setupWith(indexPath: indexPath, arrCaptureImage: arrCapturedImages)
        return cell
    }
    
    //MARK: COLLECTIONVIEW  FLOWLAYOUT DELEGATE
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return marginVertical
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return marginHorizontal
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return CGSize(width: self.frame.width, height: self.frame.height)
    }
    //MARK:- COLLECTIONVIEW DELEGATE
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if self.blockSelectedItemCollection != nil {
            self.blockSelectedItemCollection!(indexPath)
        }
    }
    
}
