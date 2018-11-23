//
//  PreviewCollectionViewCell.swift
//  Capture
//
//  Created by Hetal Chauhan on 11/22/18.
//  Copyright © 2018 Hetal. All rights reserved.
//

import UIKit

class PreviewCollectionViewCell: UICollectionViewCell {

    //MARK:- OUTLET
    @IBOutlet weak var imageCapture: UIImageView!
    
    //MARK:- PROPERTIES
    let maxScale: CGFloat = 4.0
    let minScale: CGFloat = 0.5
    var currentTransform: CGAffineTransform? = nil

    //MAR:- VIEW LIFER CYCLE
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        let pinchGesture = UIPinchGestureRecognizer(target: self, action: #selector(handlePinchGesture(recognizer:)))
        imageCapture.isUserInteractionEnabled = true
        imageCapture.contentMode = .scaleAspectFit
        imageCapture.addGestureRecognizer(pinchGesture)
        
        // Set Double Tap Gesture
        let doubleTapGesture = UITapGestureRecognizer(target: self, action:#selector(self.doubleTapAction))
        doubleTapGesture.numberOfTapsRequired = 2
        self.imageCapture.addGestureRecognizer(doubleTapGesture)

    }
    
    //MARK:- CELL SETUP
    func setupWith(indexPath: IndexPath, arrCaptureImage: [UIImage]) {
        imageCapture.image = arrCaptureImage[indexPath.row]
        
    }
    //MARK:- GESTURE HANDLER
    @objc func handlePinchGesture(recognizer: UIPinchGestureRecognizer){
        var imageViewScale: CGFloat = 1.0
        
        if let  view = recognizer.view{
            let pinchScale: CGFloat = recognizer.scale
            if imageViewScale * pinchScale < maxScale && imageViewScale * pinchScale > minScale {
                imageViewScale *= pinchScale
                view.transform = (view.transform.scaledBy(x: pinchScale, y: pinchScale))
            }
            recognizer.scale = 1.0
        }
    }
    @objc func doubleTapAction(gesture: UITapGestureRecognizer) {
        if gesture.state == UIGestureRecognizerState.ended {
            // Store current transfrom of UIImageView
            currentTransform = self.imageCapture.transform
            var doubleTapStartCenter = self.imageCapture.center
            
            var transform: CGAffineTransform! = nil
            var scale: CGFloat = 2.0 // x2 double tapped
            
            // Get current scale
            let currentScale = sqrt(abs(self.imageCapture.transform.a * self.imageCapture.transform.d - self.imageCapture.transform.b * self.imageCapture.transform.c))
            
            // Get tapped location
            let tappedLocation = gesture.location(in: self.imageCapture)
            
            var newCenter: CGPoint
            if self.maxScale < currentScale * scale { // Upper higher scale limit
                scale = self.minScale
                transform = CGAffineTransform.identity
                
                newCenter = CGPoint(x: self.frame.size.width / 2, y: self.frame.size.height / 2)
                doubleTapStartCenter = newCenter
                
            } else {
                transform = self.currentTransform!.concatenating(CGAffineTransform(scaleX: scale, y: scale))
                
                newCenter = CGPoint(
                    x: doubleTapStartCenter.x - ((tappedLocation.x - doubleTapStartCenter.x) * scale - (tappedLocation.x - doubleTapStartCenter.x)),
                    y: doubleTapStartCenter.y - ((tappedLocation.y - doubleTapStartCenter.y) * scale - (tappedLocation.y - doubleTapStartCenter.y)))
                
                // Update recrangle
                //self.setRectangleScale(scale: currentScale * scale)
            }
            
            // Update view
            UIView.animate(withDuration: 0.3, delay: 0.0, options: UIViewAnimationOptions.curveEaseOut, animations: {() -> Void in
                self.imageCapture.center = newCenter
                self.imageCapture.transform = transform
                
            }, completion: {(finished: Bool) -> Void in
            })
        }
    }

}
