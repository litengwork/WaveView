//
//  UIColorHelpers.swift
//  WaveView
//
//  Created by Fernando on 2018/6/5.
//  Copyright © 2018年 Liteng. All rights reserved.
//

import UIKit

extension UIColor {
    convenience init(rgb: Int64) {
        self.init(red: CGFloat((rgb & 0x00FF0000) >> 16) / 255.0,
                  green: CGFloat((rgb & 0x0000FF00) >> 8) / 255.0,
                  blue: CGFloat(rgb & 0x000000FF) / 255.0,
                  alpha: 1.0)
    }
    
    convenience init(rgba: Int64) {
        self.init(red: CGFloat((rgba & 0xFF000000) >> 24) / 255.0,
                  green: CGFloat((rgba & 0x00FF0000) >> 16) / 255.0,
                  blue: CGFloat((rgba & 0x0000FF00) >> 8) / 255.0,
                  alpha: CGFloat(rgba & 0x000000FF) / 255.0)
    }
    
    class var themeTradGreen: UIColor {
        return UIColor(rgb: 0x004831)
    }
    
    class var themeFreshGreen: UIColor {
        return UIColor(rgb: 0xC4D700)
    }
    
    class var themeBrandModified1: UIColor {
        return UIColor(rgb: 0x00796B)
    }
    
    class var themeBrandModified2: UIColor {
        return UIColor(rgb: 0x73AE2F)
    }
    
    class var themeBrandModified3: UIColor {
        return UIColor(rgb: 0x078D68)
    }
    
    class var themeBlack: UIColor {
        return UIColor(rgb: 0x121212)
    }
    
    class var themeGray: UIColor {
        return UIColor(rgb: 0x666666)
    }
    
    class var themeLightGray: UIColor {
        return UIColor(rgb: 0xEEEEEE)
    }
    
    class var themeWhite: UIColor {
        return UIColor(rgb: 0xFFFFFF)
    }
    
    func getHue() -> (CGFloat, CGFloat, CGFloat, CGFloat) {
        var hue: CGFloat = 0.0
        var saturation: CGFloat = 0.0
        var brightness: CGFloat = 0.0
        var alpha: CGFloat = 0.0
        getHue(&hue, saturation: &saturation, brightness: &brightness, alpha: &alpha)
        return (hue, saturation, brightness, alpha)
    }
    
    func getRgba() -> (CGFloat, CGFloat, CGFloat, CGFloat) {
        var red: CGFloat = 0.0
        var green: CGFloat = 0.0
        var blue: CGFloat = 0.0
        var alpha: CGFloat = 0.0
        getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        return (red, green, blue, alpha)
    }
}

