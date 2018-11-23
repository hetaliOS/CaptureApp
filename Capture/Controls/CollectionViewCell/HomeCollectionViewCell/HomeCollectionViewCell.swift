//
//  HomeCollectionViewCell.swift
//  Capture
//
//  Created by Hetal Chauhan on 11/20/18.
//  Copyright © 2018 Hetal. All rights reserved.
//

import UIKit

class HomeCollectionViewCell: UICollectionViewCell {
    
    //MARK:- OUTLETS
    @IBOutlet weak var viewContainer: UIView!
    @IBOutlet weak var imgCapture: UIImageView!

    //MARK:- BLOCK
    var blockForSendRequest:(()-> Void)?
    var blockForDislike:(()-> Void)?
    
    //MARK:- LIFE CYCLE
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
    
    override func layoutSubviews(){
        super.layoutSubviews()
    }
    
   
    //MARK:- CELL SETUP
    func setupWith(indexPath: IndexPath, arrCaptureImage: [UIImage]) {
        imgCapture.image = arrCaptureImage[indexPath.row]
    }
    
}
