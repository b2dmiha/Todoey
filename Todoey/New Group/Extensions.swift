//
//  Extensions.swift
//  Todoey
//
//  Created by Michael Gimara on 22/04/2019.
//  Copyright © 2019 Michael Gimara. All rights reserved.
//

import UIKit

extension UIColor {
    class func randomColor() -> UIColor {
        if let randomColor = UIColor.randomFlat() {
            return randomColor
        } else {
            let red = CGFloat.random(in: 0...1)
            let green = CGFloat.random(in: 0...1)
            let blue = CGFloat.random(in: 0...1)
            
            let randomColor = UIColor(red: red, green: green, blue: blue, alpha: 1.0)
            
            return randomColor
        }
    }
}

extension UIViewController {
    func setStatusBarStyle(_ style: UIStatusBarStyle) {
        if let statusBar = UIApplication.shared.value(forKey: "statusBar") as? UIView {
            statusBar.setValue(style == .lightContent ? UIColor.white : .black, forKey: "foregroundColor")
        }
    }
}

