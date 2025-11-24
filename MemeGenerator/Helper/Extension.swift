//
//  Extension.swift
//  MemeGenerator
//
//  Created by Emil Maharramov on 18.11.25.
//

import UIKit
import Foundation
import Kingfisher

extension UIImageView {
    
    func loadImage(_ path: String?) {
        kf.cancelDownloadTask()
        
        guard let path = path, !path.isEmpty else {
            image = nil
            return
        }
        
        if path.hasPrefix("https") {
            if let url = URL(string: path) {
                kf.setImage(with: url)
            } else {
                image = nil
            }
            return
        }
        
//        // Əks halda backend-in imageBaseUrl ilə birləşdir
//        let fullPath = NetworkHelper.shared.imageBaseUrl + path
//        
//        guard let url = URL(string: fullPath) else {
//            image = nil
//            return
//        }
//        
//        kf.setImage(with: url)
    }
}

extension Date {
    func timeAgoString() -> String {
        let now = Date()
        let seconds = Int(now.timeIntervalSince(self))

        if seconds < 60 { return "Just now" }

        let minutes = seconds / 60
        if minutes < 60 { return "\(minutes)m ago" }

        let hours = minutes / 60
        if hours < 24 { return "\(hours)h ago" }

        let days = hours / 24
        if days < 7 { return "\(days)d ago" }

        let df = DateFormatter()
        df.dateStyle = .medium
        return df.string(from: self)
    }
}

// String (ISO 8601) -> Date -> timeAgoString
extension String {
    func timeAgoString() -> String {
        let isoFormatter = ISO8601DateFormatter()
        guard let date = isoFormatter.date(from: self) else {
            return ""
        }
        return date.timeAgoString()
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

extension UIViewController {

    func showToast(message: String, type: ToastType = .error, duration: TimeInterval = 2.0) {

        // Remove old toasts
        view.subviews.filter { $0.tag == 999999 }.forEach { $0.removeFromSuperview() }

        let toastView = UIView()
        toastView.tag = 999999
        toastView.layer.cornerRadius = 12
        toastView.clipsToBounds = true
        toastView.backgroundColor = (type == .success) ? UIColor.systemGreen : UIColor.systemRed.withAlphaComponent(0.95)

        let label = UILabel()
        label.text = message
        label.textColor = .white
        label.font = UIFont.systemFont(ofSize: 15, weight: .medium)
        label.numberOfLines = 0
        label.textAlignment = .center

        toastView.addSubview(label)
        view.addSubview(toastView)

        toastView.translatesAutoresizingMaskIntoConstraints = false
        label.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            toastView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            toastView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            toastView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: -100),

            label.leadingAnchor.constraint(equalTo: toastView.leadingAnchor, constant: 12),
            label.trailingAnchor.constraint(equalTo: toastView.trailingAnchor, constant: -12),
            label.topAnchor.constraint(equalTo: toastView.topAnchor, constant: 10),
            label.bottomAnchor.constraint(equalTo: toastView.bottomAnchor, constant: -10),
        ])

        view.layoutIfNeeded()

        // Slide down animation
        UIView.animate(withDuration: 0.35) {
            toastView.transform = CGAffineTransform(translationX: 0, y: 120)
        }

        // Auto hide
        DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
            UIView.animate(withDuration: 0.35, animations: {
                toastView.transform = .identity
                toastView.alpha = 0
            }) { _ in
                toastView.removeFromSuperview()
            }
        }
    }
}

extension UILabel {
    func configureOverlay() {
        textColor = .white
        font = .boldSystemFont(ofSize: 28)
        numberOfLines = 0
        textAlignment = .center
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.9
        layer.shadowRadius = 3
        layer.shadowOffset = CGSize(width: 1, height: 1)
    }
}

extension UITextField {
    func configureField(placeholder: String) {
        self.placeholder = placeholder
        borderStyle = .roundedRect
        backgroundColor = .white
        textAlignment = .center
    }
}

extension UIButton {
    func configureAction(title: String, color: UIColor) {
        setTitle(title, for: .normal)
        backgroundColor = color
        setTitleColor(.white, for: .normal)
        layer.cornerRadius = 14
        titleLabel?.font = .systemFont(ofSize: 15, weight: .semibold)
    }
}
