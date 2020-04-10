//
//  UIImage+rezised.swift
//  Location
//
//  Created by MARC on 4/9/20.
//  Copyright © 2020 MARC. All rights reserved.
//

import UIKit

extension UIImage {
    func resize(withBounds bounds: CGSize)-> UIImage {
        let horizontalRatio = bounds.width / size.width
        let verticalRatio = bounds.height / size.height
        let ratio = min(horizontalRatio, verticalRatio)
        let newSize = CGSize(width: size.width * ratio, height: size.height * ratio)
        UIGraphicsBeginImageContextWithOptions(newSize, true, 0)
        draw(in: CGRect(origin: CGPoint.zero, size: newSize))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage!
    }
}
