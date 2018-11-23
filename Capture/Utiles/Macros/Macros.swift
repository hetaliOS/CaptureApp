//
//  Macros.swift
//  Capture
//
//  Created by Hetal Chauhan on 11/20/18.
//  Copyright © 2018 Hetal. All rights reserved.
//

import UIKit

enum VisionApiDetector: String {
    case landmarkDetectore = "LANDMARK_DETECTION"
    case textDetectore = "TEXT_DETECTION"
    case labelDetectore = "LABEL_DETECTION"
    case faceDetectore = "FACE_DETECTION"
    case logoDetectore = "LOGO_DETECTION"
}

struct ApiRequestKey {
    static var request = "requests"
    static var image   = "image"
    static var content = "content"
    static var feature = "features"
    static var type    = "type"
}
struct ApiResponseKey {
    static let landmarkAnnotation = "landmarkAnnotations"
    static let labelAnnotation = "labelAnnotations"
    static let reponses = "responses"
    static let description = "description"
    static let locations = "locations"
    static let latLong = "latLng"
    static let latitude = "latitude"
    static let longitude = "longitude"
}
