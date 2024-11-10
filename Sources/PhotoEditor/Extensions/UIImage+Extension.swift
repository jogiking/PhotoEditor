//
//  UIImage+Extension.swift
//  PhotoEditor
//
//  Created by giwan jo on 11/10/24.
//

import UIKit

extension UIImage {
    static func loadAsset(named name: String) -> UIImage? {
        #if DEBUG
        return UIImage(named: name, in: Bundle.module, with: nil)
        #else
        return UIImage(named: name)
        #endif
    }
}
