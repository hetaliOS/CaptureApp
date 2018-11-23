//
//  CaptureModel.swift
//  Capture
//
//  Created by Hetal Chauhan on 11/21/18.
//  Copyright © 2018 Hetal. All rights reserved.
//

import UIKit
struct CaptureModelKeys {
    static let idK = "id"
    static let tagK = "tag"
    static let isSyncedToServerK = "isSyncedToServer"
    static let imageBase64K = "imageBase64"
}
class CaptureModel: NSObject {
    
    //MARK:- VARIABLES
    
    var id                      : Int = 0
    var tag                     : String = ""
    var imageBase64             : String = ""
    var isSyncedToServer        : Bool = false
   
    //MARK:- INIT
    convenience init(_ dict: NSDictionary)
    {
        self.init()
        id = dict.value(forKey: CaptureModelKeys.idK) as! Int
        tag = dict.value(forKey: CaptureModelKeys.tagK) as! String
        imageBase64 = dict.value(forKey: CaptureModelKeys.imageBase64K) as! String
        if let status  = dict.value(forKey: CaptureModelKeys.isSyncedToServerK) as? Bool{
            isSyncedToServer = status
        }else if let status = dict.value(forKey: CaptureModelKeys.isSyncedToServerK) as? Int{
            isSyncedToServer = status == 1 ? true : false
        }
    }
}
