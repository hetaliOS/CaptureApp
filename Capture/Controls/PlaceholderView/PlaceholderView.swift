//
//  PlaceholderView.swift
//  Capture
//
//  Created by Hetal Chauhan on 11/21/18.
//  Copyright © 2018 Hetal. All rights reserved.
//

import UIKit

class PlaceholderView: UIView {

    //MARK:- OUTLETS
    @IBOutlet var contentView: UIView!
    @IBOutlet weak var btnCapture: UIButton!
    @IBOutlet weak var lblMessage: UILabel!
    
    //MARK:- BLOCK
    var blockForBtnCapture:(()-> Void)?
    // MARK:- INIT
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.commonInit()
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    private func commonInit()    {
        // LOADING NIB FILE
        Bundle.main.loadNibNamed("PlaceholderView", owner: self, options: nil)
        self.addSubview(self.contentView!);
        
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        if((self.superview) != nil){
            self.frame = CGRect(x: 0, y: 0, width: (self.superview?.frame.size.width)!, height: (self.superview?.frame.size.height)!)
            self.contentView?.frame = self.frame
        }
    }
    func setMessage(_ message: String){
        lblMessage.text = message

    }
    @IBAction func btnCapture(_ sender: Any) {
        if blockForBtnCapture != nil{
            blockForBtnCapture!()
        }
    }


}
