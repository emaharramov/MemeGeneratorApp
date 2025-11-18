//
//  Extension.swift
//  MemeGenerator
//
//  Created by Emil Maharramov on 18.11.25.
//

import UIKit
import Foundation
//import Kingfisher

extension UIImageView {
    
    func loadImage(url: String) {
        let fullPath = "NetworkHelper.shared.imageBaseUrl + url"
        guard let url = URL(string: fullPath) else { return }
//        self.kf.setImage(with: url)
    }
}

extension UIViewController {
    func showAlert(title: String = "Error",
                   message: String? = nil, actionTitle: String? = "Ok") {
        let controller = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: actionTitle, style: .cancel)
        controller.addAction(action)
        present(controller, animated: true)
    }
}

extension UITextField {
    func setLeftPaddingPoints(_ amount: CGFloat) {
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: amount, height: self.frame.height))
        self.leftView = paddingView
        self.leftViewMode = .always
    }
    
    func setRightPaddingPoints(_ amount: CGFloat) {
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: amount, height: self.frame.height))
        self.rightView = paddingView
        self.rightViewMode = .always
    }
}

extension UIColor {
    convenience init(hexStr: String, colorAlpha: CGFloat = 1) {
        var rgbHexInt: UInt64 = 0
        
        let scanner = Scanner(string: hexStr)
        scanner.scanHexInt64(&rgbHexInt)
        
        self.init(red: CGFloat((rgbHexInt & 0xff0000) >> 16) / 0xff,
                  green: CGFloat((rgbHexInt & 0xff00) >> 8) / 0xff,
                  blue: CGFloat(rgbHexInt & 0xff) / 0xff,
                  alpha: colorAlpha)
    }
}

extension Encodable {
    func toDictionary() -> [String: Any]? {
        guard let data = try? JSONEncoder().encode(self) else { return nil }
        return (try? JSONSerialization.jsonObject(with: data)) as? [String: Any]
    }
}
