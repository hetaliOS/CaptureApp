//
//  HomeCollectionview.swift
//  Capture
//
//  Created by Hetal Chauhan on 11/20/18.
//  Copyright © 2018 Hetal. All rights reserved.
//

import UIKit

class HomeCollectionview: UICollectionView {
    
    let cellIdentifier = "HomeCollectionViewCell"

    // MARK:- PROPERTIES
    private let marginVertical:CGFloat =  getProportionalWidth(width: 40)
    private let marginHorizontal:CGFloat = getProportionalHeight(height: 36)
    private let marginLeftRight:CGFloat = getProportionalWidth(width: 30)
    private let topMargin:CGFloat = getProportionalHeight(height: 30)
    
    var arrCapturedImages: [UIImage] = []
    let placeholderView = PlaceholderView()
    var isSearchCollection: Bool = true
    var isComeFromSearch: Bool = false
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
    }
    
    
    // MARK:- SETUP COLLECTIONVIEW
    
    func doSetupCollectionView() {
        
        self.register(UINib(nibName: cellIdentifier, bundle: nil), forCellWithReuseIdentifier: cellIdentifier)
        
        let flowLayout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        flowLayout.scrollDirection = .vertical
        self.alwaysBounceVertical = true;
        
        self.collectionViewLayout = flowLayout
        self.allowsMultipleSelection = true
        self.delegate = self
        self.dataSource = self
        
        //Set placeholder view
        placeholderView.frame = CGRect(x: 0, y: 0, width: self.frame.size.width, height: self.frame.size.height)
        placeholderView.blockForBtnCapture = {[weak self]()in
            if self?.blockForTakeCapture != nil{
                self?.blockForTakeCapture!()
            }
        }
       
        self.addSubview(placeholderView)
    }
}
extension HomeCollectionview: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout{
    
    // MARK:- UICOLLECTIONVIEW DATASOURCE
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if arrCapturedImages.count == 0{
              placeholderView.isHidden = false
            if self.isComeFromSearch == true{
                placeholderView.btnCapture.isEnabled = false
                let message: String = "No Capture Found"
                placeholderView.setMessage(message)
            }else{
                placeholderView.setMessage("Take Capture")
            }
        }else{
            
            placeholderView.isHidden = true
            self.contentInset = UIEdgeInsetsMake(topMargin, marginLeftRight, 0, marginLeftRight)
        }
        return arrCapturedImages.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellIdentifier, for: indexPath)  as! HomeCollectionViewCell
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
        
        let cellWidth   = ( self.frame.size.width - (marginLeftRight * 3.5))/2
        let cellHeight  = cellWidth
        return CGSize(width: cellWidth, height: cellHeight)
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        return CGSize(width: SCREEN_WIDTH , height: getProportionalHeight(height: 160))
    }
    
    //MARK:- COLLECTIONVIEW DELEGATE
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if self.blockSelectedItemCollection != nil {
            self.blockSelectedItemCollection!(indexPath)
        }
    }

}
