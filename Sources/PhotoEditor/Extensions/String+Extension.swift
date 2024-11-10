//
//  String+Extension.swift
//  PhotoEditor
//
//  Created by giwan jo on 11/10/24.
//

import UIKit

extension String {
    /// String을 UIColor로 변환하는 Extension
    var stringToColor: UIColor {
        // 문자열의 공백 제거 및 소문자로 변환
        let hex = self.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        
        // "#" 기호 제거
        let cleanedHex = hex.hasPrefix("#") ? String(hex.dropFirst()) : hex
        
        // 문자열 길이에 따른 처리
        var int: UInt64 = 0
        guard Scanner(string: cleanedHex).scanHexInt64(&int) else { return UIColor.clear }
        
        switch cleanedHex.count {
        case 3: // RGB (12-bit)
            let r = (int >> 8) * 17
            let g = ((int >> 4) & 0xF) * 17
            let b = (int & 0xF) * 17
            return UIColor(red: CGFloat(r) / 255, green: CGFloat(g) / 255, blue: CGFloat(b) / 255, alpha: 1.0)
        case 4: // ARGB (16-bit)
            let a = (int >> 12) * 17
            let r = ((int >> 8) & 0xF) * 17
            let g = ((int >> 4) & 0xF) * 17
            let b = (int & 0xF) * 17
            return UIColor(red: CGFloat(r) / 255, green: CGFloat(g) / 255, blue: CGFloat(b) / 255, alpha: CGFloat(a) / 255)
        case 6: // RGB (24-bit)
            let r = (int >> 16) & 0xFF
            let g = (int >> 8) & 0xFF
            let b = int & 0xFF
            return UIColor(red: CGFloat(r) / 255, green: CGFloat(g) / 255, blue: CGFloat(b) / 255, alpha: 1.0)
        case 8: // ARGB (32-bit)
            let a = (int >> 24) & 0xFF
            let r = (int >> 16) & 0xFF
            let g = (int >> 8) & 0xFF
            let b = int & 0xFF
            return UIColor(red: CGFloat(r) / 255, green: CGFloat(g) / 255, blue: CGFloat(b) / 255, alpha: CGFloat(a) / 255)
        default:
            return UIColor.clear
        }
    }
}
