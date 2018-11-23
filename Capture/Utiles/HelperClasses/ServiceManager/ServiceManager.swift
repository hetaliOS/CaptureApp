//
//  ServiceManager.swift
//  Capture
//
//  Created by Hetal Chauhan on 11/20/18.
//  Copyright © 2018 Hetal. All rights reserved.
//

import UIKit
import Alamofire
import SVProgressHUD
let Service = ServiceManager.shared

class ServiceManager: NSObject {
    
    // MARK: - SHARED MANAGER
    static let shared = ServiceManager()
    let api_key = "AIzaSyBZc8Eltd5EDtj1yDsDSBGobP85mzUiPLk"
    
    //MARK:- SINGLE IMAGE DETECTION
    func imageDetection(model: CaptureModel, andCompletion completion:@escaping (_ isSuccess:Bool, _ message:String, _ tags:[String]?) -> Void){
        
        let cloudApiURL  = "https://vision.googleapis.com/v1/images:annotate?key=\(api_key)"
        
        var params : [String: Any] = [:]
        params[ApiRequestKey.request] = [
            [ApiRequestKey.image: [ApiRequestKey.content: model.imageBase64],
             ApiRequestKey.feature: [[ApiRequestKey.type:VisionApiDetector.landmarkDetectore.rawValue],[ApiRequestKey.type:VisionApiDetector.labelDetectore.rawValue]]
            ]]
        
        callGET_POSTApiWithNetCheck(isGet: false, url: cloudApiURL, headersRequired: false, params: params, isLoader: true) { (message, responseDict, status, isInternetAvailable) in
            
            if isInternetAvailable
            {
                var tagArray : [String] = []
                let responseArray = responseDict?.value(forKey: ApiResponseKey.reponses) as! NSArray
                for response in responseArray{
                    if let detection = response as? NSDictionary{
                        //Label Detection
                        if let labelDetection = detection.value(forKey: ApiResponseKey.labelAnnotation) as? NSArray{
                            for labelDect in labelDetection{
                                if let dict = labelDect as? NSDictionary{
                                    let tag = dict.value(forKey: ApiResponseKey.description) as! String
                                    tagArray.append(tag.lowercased())
                                }
                            }
                        }
                        
                        //Landmark Detection
                        if let landmarkDetection = detection.value(forKey: ApiResponseKey.landmarkAnnotation) as? NSArray{
                            for landmark in landmarkDetection{
                                
                                //Get Image discription
                                if let dict = landmark as? NSDictionary{
                                    let tag = dict.value(forKey: ApiResponseKey.description) as! String

                                    tagArray.append(tag.lowercased())
                                    
                                    //Get Address from latitude and longitude
                                    if let locations = dict.value(forKey: ApiResponseKey.locations) as? NSArray{
                                        for locationDict in locations{
                                            if let latlongDict = locationDict as? NSDictionary{
                                                if let latlong = latlongDict.value(forKey: ApiResponseKey.latLong) as? NSDictionary{
                                                    let latitude = "\(latlong.value(forKey: ApiResponseKey.latitude)!)"
                                                    let longitude = "\(latlong.value(forKey: ApiResponseKey.longitude)!)"
                                                    getAddressFromLatLong(latitude: latitude, withLongitude: longitude , completion: { (isSucess, address) in
                                                        tagArray.append(contentsOf: address!)
                                                         print(tagArray)
                                                        //IF land mark found then complition with landmark annotation
                                                        completion(true, "", tagArray)

                                                    })
                                                }
                                                
                                            }
                                        }
                                    }
                                }
                            }
                        }else{
                            //If No landmark found the n complition with label annotations
                            completion(true, "", tagArray)
                        }
                    }
                }
                print(tagArray)
            }
        }
    }
    
    //MARK:- MULTIPLE IMAGE DETECTION
    func multipleImageDetection(captures: [CaptureModel], andCompletion completion:@escaping (_ isSuccess:Bool, _ message:String, _ capturesArray:[CaptureModel]?) -> Void){
        
        let cloudApiURL  = "https://vision.googleapis.com/v1/images:annotate?key=\(api_key)"
        var captureArray = captures
        var params : [String: Any] = [:]
        var multipleImageArray : [[String:Any]] = []
        for model in captures{
            multipleImageArray.append([ApiRequestKey.image: [ApiRequestKey.content: model.imageBase64],
                                       ApiRequestKey.feature: [[ApiRequestKey.type:VisionApiDetector.landmarkDetectore.rawValue],[ApiRequestKey.type:VisionApiDetector.labelDetectore.rawValue]]
                ])
        }
        params[ApiRequestKey.request] = multipleImageArray
        callGET_POSTApiWithNetCheck(isGet: false, url: cloudApiURL, headersRequired: false, params: params, isLoader: false) { (message, responseDict, status, isInternetAvailable) in
            
            if isInternetAvailable
            {
                guard status == true else{return}
                
                var tagArray : [String] = []
                let responseArray = responseDict?.value(forKey: ApiResponseKey.reponses) as! NSArray
                for i in 0..<responseArray.count{
                    let response = responseArray[i]
                    if let detection = response as? NSDictionary{
                        //Label Detection
                        if let labelDetection = detection.value(forKey: ApiResponseKey.labelAnnotation) as? NSArray{
                            for labelDect in labelDetection{
                                if let dict = labelDect as? NSDictionary{
                                    let tag = dict.value(forKey: ApiResponseKey.description) as! String
                                    tagArray.append(tag.lowercased())
                                }
                            }
                        }
                        
                        //Landmark Detection
                        if let landmarkDetection = detection.value(forKey: ApiResponseKey.landmarkAnnotation) as? NSArray{
                            for landmark in landmarkDetection{
                                
                                //Get Image discription
                                if let dict = landmark as? NSDictionary{
                                    let tag = dict.value(forKey: ApiResponseKey.description) as! String
                                    
                                    tagArray.append(tag.lowercased())
                                    
                                    //Get Address from latitude and longitude
                                    if let locations = dict.value(forKey: ApiResponseKey.locations) as? NSArray{
                                        for locationDict in locations{
                                            if let latlongDict = locationDict as? NSDictionary{
                                                if let latlong = latlongDict.value(forKey: ApiResponseKey.latLong) as? NSDictionary{
                                                    let latitude = "\(latlong.value(forKey: ApiResponseKey.latitude)!)"
                                                    let longitude = "\(latlong.value(forKey: ApiResponseKey.longitude)!)"
                                                    getAddressFromLatLong(latitude: latitude, withLongitude: longitude , completion: { (isSucess, address) in
                                                        tagArray.append(contentsOf: address!)
                                                        print(tagArray)
                                                        //IF land mark found then complition with landmark annotation
                                                        captureArray[i].tag = tagArray.joined(separator: ",")
                                                        captureArray[i].isSyncedToServer = true
                                                        tagArray.removeAll()
                                                        
                                                    })
                                                }
                                                
                                            }
                                        }
                                    }
                                }
                            }
                        }else{
                            captureArray[i].tag = tagArray.joined(separator: ",")
                            captureArray[i].isSyncedToServer = true
                            tagArray.removeAll()
                            //If No landmark found the n complition with label annotations
                        }
                    }
                }
                completion(true, "", captureArray)
                print(tagArray)
            }
        }
    }
    //MARK:- ******** COMMON POST METHOD *********
    private func callGET_POSTApiWithNetCheck(isGet:Bool, url : String, headersRequired : Bool, params : [String : Any]?,isLoader:Bool, completionHandler : @escaping (_ message: String?,_ responseDict: NSDictionary?,_ status: Bool, _ isInternetAvailable: Bool) -> Void)
    {
        if !RechabilityManager.shared.isInternetAvailableForAllNetworks()
        {
            self.AlertInternetNotAvailable()
            completionHandler(nil,nil,false,false)
            return
        }
        
        if isLoader
        {
            showLoader()
        }
        
        let headers:[String:String] = [:]
        
             showActivityIndicator()
        // URLEncoding.default
        Alamofire.request(url, method: isGet ? .get : .post, parameters: params, encoding: JSONEncoding.default, headers: nil).responseString { (response) in
            print(response)
        }
        Alamofire.request(url, method: isGet ? .get : .post, parameters: params, encoding: JSONEncoding.default, headers: nil).responseJSON { (response) in
            
            if isLoader
            {
                self.hideLoader()
            }
            
            self.hideActivityIndicator()
            
            switch response.result
            {            case .success(let JSON):
                
                print("JSON Responsess:", response)
                
                if let dictJson = JSON as? NSDictionary
                {
                    if dictJson.allKeys.count == 0{
                        completionHandler("",dictJson,false,true)
                    }else{
                        completionHandler("",dictJson,true,true)
                    }
                   
                }
                else
                {
                    let error : String = (response.result.error?.localizedDescription)! as String
                    
                    completionHandler(error,nil,false,true)
                }
                
            case .failure( _):
                
                let error : String = (response.result.error?.localizedDescription)! as String
                
                completionHandler(error,nil,false,true)
            }
        }
    }
    
   
    // MARK:-
    
    /// Show activity indicator.
    private func showActivityIndicator(){
        UIApplication.shared.isNetworkActivityIndicatorVisible =  true
    }
    
    
    /// Hide activity indicator.
    public func hideActivityIndicator(){
        UIApplication.shared.isNetworkActivityIndicatorVisible =  false
    }
    
    
    /// Show default loader.
    private func showLoader() {
        showLoaderWithText(text: "")
    }
    private func showLoaderWithText(text:String){
        
        OperationQueue.main.addOperation {
            SVProgressHUD.setDefaultStyle(.custom)
            SVProgressHUD.setDefaultMaskType(.custom)
            SVProgressHUD.setDefaultAnimationType(.flat)
            SVProgressHUD.setBackgroundColor(UIColor.clear)
            SVProgressHUD.setRingRadius(30)
            SVProgressHUD.setRingThickness(5)
            SVProgressHUD.setForegroundColor(UIColor.white)
            if(text.count > 0){
                SVProgressHUD.show(withStatus: text)
            }else{
                SVProgressHUD.show()
            }
        }
    }
    
    /// Hide default loader.
    private func hideLoader(){
        OperationQueue.main.addOperation {
            SVProgressHUD.dismiss()
        }
    }
    
    /// Default internet alert message
    func AlertInternetNotAvailable() {
        
        self.showAlertWithTitle(title: Bundle.main.infoDictionary![kCFBundleNameKey as String] as! String,
                                andMessage: "Internet connection is not available. Please check your internet connection and try again.",
                                buttons: ["Okay"]) { (index) in  }
        
    }
    
    func isInternetAvailable() -> Bool {
        
        if !RechabilityManager.shared.isInternetAvailableForAllNetworks(){
            self.AlertInternetNotAvailable()
            return false
        }else{
            return true
        }
        
    }
    //Convert JsonString to Dictionary
    func convertToDictionary(text: String) -> [String: Any]? {
        if let data = text.data(using: .utf8) {
            do {
                return try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
            } catch {
                print(error.localizedDescription)
            }
        }
        return nil
    }
    
    /// Display alert with title and message
    private func showAlertWithTitle(title:String,
                                    andMessage message:String,
                                    buttons:[String],
                                    completion:((_ index:Int) -> Void)!) -> Void {
        
        
        let newMessage = message
        let alertController = UIAlertController(title: title, message: newMessage, preferredStyle: .alert)
        for index in 0..<buttons.count    {
            
            let action = UIAlertAction(title: buttons[index], style: .default, handler: {
                (alert: UIAlertAction!) in
                if(completion != nil){
                    completion(index)
                }
            })
            
            alertController.addAction(action)
        }
        
        UIApplication.shared.delegate!.window!?.rootViewController!.present(alertController, animated: true, completion: nil)
        
        //UIApplication.topMostController.present(alertController, animated: true, completion: nil)
        
    }
    
    // MARK:-
    
    /// Convert string from Dictionary.
    ///
    /// - Parameter dict: NSDictionary
    /// - Returns: value in string
    private func getStringFromDictionary(dict:Any) -> String{
        var strJson = ""
        do {
            let data = try JSONSerialization.data(withJSONObject: dict, options: JSONSerialization.WritingOptions.prettyPrinted)
            strJson = String(data: data, encoding: String.Encoding.utf8)!
        } catch let error as NSError {
            print("json error: \(error.localizedDescription)")
        }
        
        return strJson
    }
    
    
    //MARK:- ******** APP APIS *********
    
    //MARK:- ***************** LOGIN - LOGOUT  AND USER PROFILE API *****************
    
    //MARK: Login Api Call
    
    /*
     func loginWithObject(params:[String:Any],isLoader:Bool, andCompletion completion:@escaping (_ isSuccess:Bool, _ message:String?,_ user:CMSUserModel?) -> Void)
     {
     
     callPOSTApiWithNetCheck(url: ApiURL.loginApiURL, headersRequired: false, params: params,isLoader: isLoader) { (resMessage,resDict, status,isInternetAvailable) in
     
     if isInternetAvailable
     {
     if status
     {
     let dictResponse = resDict?.object_forKeyWithValidationForClass_NSDictionary(aKey: ResponseKeys.dataKey)
     
     let currUser = CMSUserModel.init(dict: dictResponse!)
     
     CMSUserModel.shared.saveUserWith(storedUser: currUser)
     
     completion(status,resMessage,currUser)
     }else
     {
     completion(status,resMessage,nil)
     }
     }
     }
     }
     */
    
}
