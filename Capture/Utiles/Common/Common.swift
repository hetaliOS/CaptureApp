//
//  Common.swift
//  Capture
//
//  Created by Hetal Chauhan on 11/20/18.
//  Copyright © 2018 Hetal. All rights reserved.
//

import UIKit
import Foundation
import CoreLocation
//MARK:- SCREEN WIDTH/HEIGHT
let SCREEN_HEIGHT = UIDevice.screenHeight
let SCREEN_WIDTH = UIDevice.screenWidth

// MARK: - GET PROPORTIONAL TYPE
//Get proposonal width as per device
func getProportionalWidth(width:CGFloat) -> CGFloat {
    return ((UIDevice.screenWidth * width)/750)
}
//Get proposonal height as per device
func getProportionalHeight(height:CGFloat) -> CGFloat {
    
    if UIDevice.screenHeight == 812 || UIDevice.screenWidth == 812{
        return ((667 * height)/1334)
        
    }else{
        return (( UIDevice.screenHeight * height)/1334)
    }
    
}

//MARK:- ALERT CONTROLLER
func showAlertWithTitleFromVC(vc:UIViewController, title:String,
                                      andMessage message:String,
                                      buttons:[String], completion:((_ index:Int) -> Void)!) -> Void {
    
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
    vc.present(alertController, animated: true, completion: nil)
}
//MARK:-

/// Get Address of locatin from lat lon
///
/// - Parameters:
///   - latitude: place latitude
///   - longitude: place longitude
func getAddressFromLatLong(latitude: String, withLongitude longitude: String, completion:@escaping (_ isSuccess:Bool, _ address:[String]?) -> Void){
    var center : CLLocationCoordinate2D = CLLocationCoordinate2D()
    let lat: Double = Double("\(latitude)")!
    //21.228124
    let lon: Double = Double("\(longitude)")!
    //72.833770
    let ceo: CLGeocoder = CLGeocoder()
    center.latitude = lat
    center.longitude = lon
    let loc: CLLocation = CLLocation(latitude:center.latitude, longitude: center.longitude)
    ceo.reverseGeocodeLocation(loc, completionHandler:
        {(placemarks, error) in
            if (error != nil)
            {
                print("reverse geodcode fail: \(error!.localizedDescription)")
            }
            let pm = placemarks! as [CLPlacemark]
            
            if pm.count > 0 {
                let pm = placemarks![0]
                var address : [String] = []
                if pm.subLocality != nil {
                    address.append(pm.subLocality!.lowercased())
                }
                if pm.thoroughfare != nil {
                    address.append(pm.thoroughfare!.lowercased())
                }
                if pm.locality != nil {
                     address.append(pm.locality!.lowercased())
                }
                if pm.country != nil {
                     address.append(pm.country!.lowercased())
                }
                
                print(address)
                completion(true, address)
            }else{
                completion(false, [])
            }
    })
}
/// Resize image from original image
///
/// - Parameters:
///   - imageSize: resize image scale
///   - image: UIImage
/// - Returns: Retun Image Data
func resizeImage(_ imageSize: CGSize, image: UIImage) -> Data {
    UIGraphicsBeginImageContext(imageSize)
    image.draw(in: CGRect(x: 0, y: 0, width: imageSize.width, height: imageSize.height))
    let newImage = UIGraphicsGetImageFromCurrentImageContext()
    let resizedImage = UIImagePNGRepresentation(newImage!)
    UIGraphicsEndImageContext()
    return resizedImage!
}
//MARK:-
extension UIViewController{
    
    // MARK:- UIViewController Functions
    /// Load your VieweContoller
    ///
    /// - Returns: self
    class func loadController(strStoryBoardName : String = "Main") -> Self {
        return instantiateViewControllerFromMainStoryBoard(strStoryBoardName: strStoryBoardName)
    }
    
    /// Set instantiat ViewController
    ///
    /// - Returns: self
    class func instantiateViewControllerFromMainStoryBoard<T>(strStoryBoardName : String) -> T{
        let controller  = UIStoryboard(name: strStoryBoardName, bundle: nil).instantiateViewController(withIdentifier: String(describing: self)) as! T
        return controller
    }

}
//MARK:-
extension UIImage{
    func convertToBase64String()-> String{
        
        var imageData: Data = UIImagePNGRepresentation(self)!
        // Resize the image if it exceeds the 2MB API limit
        if (imageData.count > 2097152) {
            let oldSize: CGSize = self.size
            let newSize: CGSize = CGSize(width: 800, height: oldSize.height / oldSize.width * 800)
            imageData = resizeImage(newSize, image: self)
        }
        
        let strBase64 = imageData.base64EncodedString(options: .endLineWithCarriageReturn)
        return strBase64
    }
}
extension String
{
    
}

//MARK:-
extension String{
    //Convert to images
    func convertToImage() -> UIImage {
        let dataDecoded : Data = Data(base64Encoded: self, options: .ignoreUnknownCharacters)!
        let decodedimage = UIImage(data: dataDecoded)
        return decodedimage!
    }
    
    //Trim white space
    func trimWhiteSpace() -> String{
        return self.trimmingCharacters(in: NSCharacterSet.whitespaces)
    }
}
private extension UIDevice {
    
    enum DeviceType:Int {
        case iPhone4or4s
        case iPhone5or5s
        case iPhone6or6s
        case iPhone6por6sp
        case iPhoneX
        case iPad
    }
    
    static var deviceType : DeviceType {
        // Need to match width also because if device is in portrait mode height will be different.
        if UIDevice.screenHeight == 480 || UIDevice.screenWidth == 480 {
            return DeviceType.iPhone4or4s
        } else if UIDevice.screenHeight == 568 || UIDevice.screenWidth == 568 {
            return DeviceType.iPhone5or5s
        } else if UIDevice.screenHeight == 667 || UIDevice.screenWidth == 667{
            return DeviceType.iPhone6or6s
        } else if UIDevice.screenHeight == 736 || UIDevice.screenWidth == 736{
            return DeviceType.iPhone6por6sp
        } else if UIDevice.screenHeight == 812 || UIDevice.screenWidth == 812{
            return DeviceType.iPhoneX
        } else {
            return DeviceType.iPad
        }
    }
    
    static var screenHeight : CGFloat {
        return UIScreen.main.bounds.size.height
    }
    static var screenWidth : CGFloat {
        return UIScreen.main.bounds.size.width
    }
    
}

