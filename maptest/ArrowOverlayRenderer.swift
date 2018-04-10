//
//  arrowOverlay.swift
//  maptest
//
//  Created by Abin Baby on 05/04/2018.
//  Copyright © 2018 Abin Baby. All rights reserved.
//

import Foundation
import UIKit
import MapKit

class MapOverlayView: MKOverlayRenderer {

    var overlayImage: UIImage
    var angle: CGFloat

    init(overlay: MKOverlay, overlayImage:UIImage, angle: CGFloat) {
        self.overlayImage = overlayImage
        self.angle = angle
        super.init(overlay: overlay)
    }

    override func draw(_ mapRect: MKMapRect, zoomScale: MKZoomScale, in context: CGContext) {
 
        let mapImage = overlayImage.cgImage
        let mapRect = rect(for: overlay.boundingMapRect)
        
        // Calculate centre point on which image should be rotated
        let centerPoint = CGPoint(x: mapRect.midX, y: mapRect.midY)
        
        let a = sqrt(pow(centerPoint.x, 2.0) + pow(centerPoint.y, 2.0))
        
        let sub1 = (centerPoint.y / a) * cos(angle / 2.0)
        let sub2 = (centerPoint.x / a) * sin(angle / 2.0)
        let deltaX = -2 * a * sin((0 - angle) / 2.0) * (sub1 + sub2)
        
        let sub3 = (centerPoint.x / a) * cos(angle / 2.0)
        let sub4 = (centerPoint.y / a) * sin(angle / 2.0)
        let deltaY = 2 * a * sin((0 - angle) / 2.0) * (sub3 - sub4)
        
        context.translateBy(x: deltaX, y: deltaY)
        context.rotate(by: angle)
        context.draw(mapImage!, in: mapRect)
    }
}


class MapOverlay: NSObject, MKOverlay {

    var coordinate: CLLocationCoordinate2D
    var boundingMapRect: MKMapRect
    var identifier: String?

    init(identifier:String, coord: CLLocationCoordinate2D, rect: MKMapRect) {
        self.coordinate = coord
        self.boundingMapRect = rect
        self.identifier = identifier
    }
}



