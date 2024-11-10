//
//  UIView+Extension.swift
//  PhotoEditor
//
//  Created by giwan jo on 11/10/24.
//

import UIKit

extension UIView {
    func addBorder(_ arr_edge: [UIRectEdge], color: UIColor, width: CGFloat) {
        arr_edge.forEach { edge in
            switch edge {
            case .top:
                addTopBorder(with: color, andWidth: width)
            case .bottom:
                addBottomBorder(with: color, andWidth: width)
            case .left:
                addLeftBorder(with: color, andWidth: width)
            case .right:
                addRightBorder(with: color, andWidth: width)
            case .all:
                addTopBorder(with: color, andWidth: width)
                addBottomBorder(with: color, andWidth: width)
                addLeftBorder(with: color, andWidth: width)
                addRightBorder(with: color, andWidth: width)
            default:
                break
            }
        }
    }
    
    private func addTopBorder(with color: UIColor?, andWidth borderWidth: CGFloat) {
        let border = UIView()
        border.backgroundColor = color
        border.autoresizingMask = [.flexibleWidth, .flexibleBottomMargin]
        border.frame = CGRect(x: 0, y: 0, width: frame.size.width, height: borderWidth)
        addSubview(border)
    }
    
    private func addBottomBorder(with color: UIColor?, andWidth borderWidth: CGFloat) {
        let border = UIView()
        border.backgroundColor = color
        border.autoresizingMask = [.flexibleWidth, .flexibleTopMargin]
        border.frame = CGRect(x: 0, y: frame.size.height - borderWidth, width: frame.size.width, height: borderWidth)
        addSubview(border)
    }
    
    private func addLeftBorder(with color: UIColor?, andWidth borderWidth: CGFloat) {
        let border = UIView()
        border.backgroundColor = color
        border.frame = CGRect(x: 0, y: 0, width: borderWidth, height: frame.size.height)
        border.autoresizingMask = [.flexibleHeight, .flexibleRightMargin]
        addSubview(border)
    }
    
    private func addRightBorder(with color: UIColor?, andWidth borderWidth: CGFloat) {
        let border = UIView()
        border.backgroundColor = color
        border.autoresizingMask = [.flexibleHeight, .flexibleLeftMargin]
        border.frame = CGRect(x: frame.size.width - borderWidth, y: 0, width: borderWidth, height: frame.size.height)
        addSubview(border)
    }
}
