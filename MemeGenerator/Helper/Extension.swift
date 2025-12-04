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
        self.image = nil

        guard
            let path = path,
            !path.isEmpty,
            let url = URL(string: path)
        else { return }

        kf.setImage(with: url)
    }
}

extension UIEdgeInsets {
    init(all value: CGFloat) {
        self.init(top: value, left: value, bottom: value, right: value)
    }
}

extension Date {
    func timeAgoString() -> String {
        let seconds = Int(Date().timeIntervalSince(self))

        let minute = 60
        let hour = 60 * minute
        let day = 24 * hour

        switch seconds {
        case 0..<minute:      return "\(seconds)s ago"
        case minute..<hour:   return "\(seconds / minute)m ago"
        case hour..<day:      return "\(seconds / hour)h ago"
        default:              return "\(seconds / day)d ago"
        }
    }
}

extension UIColor {
    static let mgBackground   = UIColor(red: 33/255, green: 26/255, blue: 17/255, alpha: 1)
    static let mgLightBackground   = UIColor(red: 33/255, green: 26/255, blue: 17/255, alpha: 0.9)
    static let mgCard         = UIColor(red: 45/255, green: 34/255, blue: 23/255, alpha: 1)
    static let mgCardStroke   = UIColor(white: 1, alpha: 0.05)
    static let mgTextPrimary  = UIColor.white
    static let mgTextSecondary = UIColor.white.withAlphaComponent(0.65)
    static let mgAccent       = UIColor(red: 171/255, green: 120/255, blue: 52/255, alpha: 1)
    static let textFieldTextColor = UIColor(red: 0.70, green: 0.52, blue: 0.26, alpha: 1.0)
    static let cardBg = UIColor.systemGray6.withAlphaComponent(0.9)
}

extension String {
    func timeAgoString() -> String {
        let isoFormatter = ISO8601DateFormatter()
        isoFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]

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

extension UICollectionView {
    func dequeueCell<T: UICollectionViewCell>(
        _ type: T.Type,
        for indexPath: IndexPath
    ) -> T {
        guard let cell = dequeueReusableCell(
            withReuseIdentifier: String(describing: type),
            for: indexPath
        ) as? T else {
            fatalError("Failed to dequeue cell of type \(type)")
        }
        return cell
    }
}

extension UITableView {
    func dequeueCell<T: UITableViewCell>(
        _ type: T.Type,
        for indexPath: IndexPath
    ) -> T {
        guard let cell = dequeueReusableCell(
            withIdentifier: String(describing: type),
            for: indexPath
        ) as? T else {
            fatalError("Failed to dequeue cell of type \(type)")
        }
        return cell
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
    enum ToastType {
        case success
        case error
        case info
    }

    func showToast(
        message: String,
        type: ToastType = .error,
        duration: TimeInterval = 2.0
    ) {
        let container = toastContainerView()

        container.subviews
            .filter { $0.tag == 999_999 }
            .forEach { $0.removeFromSuperview() }

        let toastView = UIView()
        toastView.tag = 999_999
        toastView.layer.cornerRadius = 18
        toastView.clipsToBounds = true

        let blurEffect = UIBlurEffect(style: .systemThinMaterialDark)
        let blurView = UIVisualEffectView(effect: blurEffect)
        blurView.translatesAutoresizingMaskIntoConstraints = false
        toastView.addSubview(blurView)

        let accentView = UIView()
        accentView.translatesAutoresizingMaskIntoConstraints = false
        accentView.layer.cornerRadius = 3
        accentView.layer.masksToBounds = true

        let iconView = UIImageView()
        iconView.translatesAutoresizingMaskIntoConstraints = false
        iconView.tintColor = .white
        iconView.contentMode = .scaleAspectFit

        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = message
        label.textColor = .white
        label.font = UIFont.systemFont(ofSize: 15, weight: .medium)
        label.numberOfLines = 0

        switch type {
        case .success:
            accentView.backgroundColor = UIColor.systemGreen
            iconView.image = UIImage(systemName: "checkmark.circle.fill")
        case .error:
            accentView.backgroundColor = UIColor.systemRed
            iconView.image = UIImage(systemName: "exclamationmark.triangle.fill")
        case .info:
            accentView.backgroundColor = .mgAccent
            iconView.image = UIImage(systemName: "info.circle.fill")
        }

        toastView.layer.shadowColor = UIColor.black.cgColor
        toastView.layer.shadowOpacity = 0.25
        toastView.layer.shadowRadius = 10
        toastView.layer.shadowOffset = CGSize(width: 0, height: 4)

        container.addSubview(toastView)
        toastView.addSubview(accentView)
        toastView.addSubview(iconView)
        toastView.addSubview(label)

        toastView.translatesAutoresizingMaskIntoConstraints = false

        let guide = container.safeAreaLayoutGuide

        NSLayoutConstraint.activate([
            toastView.leadingAnchor.constraint(equalTo: guide.leadingAnchor, constant: 16),
            toastView.trailingAnchor.constraint(equalTo: guide.trailingAnchor, constant: -16),
            toastView.topAnchor.constraint(equalTo: guide.topAnchor, constant: 8),

            blurView.leadingAnchor.constraint(equalTo: toastView.leadingAnchor),
            blurView.trailingAnchor.constraint(equalTo: toastView.trailingAnchor),
            blurView.topAnchor.constraint(equalTo: toastView.topAnchor),
            blurView.bottomAnchor.constraint(equalTo: toastView.bottomAnchor),

            accentView.leadingAnchor.constraint(equalTo: toastView.leadingAnchor, constant: 8),
            accentView.centerYAnchor.constraint(equalTo: toastView.centerYAnchor),
            accentView.widthAnchor.constraint(equalToConstant: 4),
            accentView.heightAnchor.constraint(equalTo: toastView.heightAnchor, constant: -12),

            iconView.leadingAnchor.constraint(equalTo: accentView.trailingAnchor, constant: 10),
            iconView.centerYAnchor.constraint(equalTo: toastView.centerYAnchor),
            iconView.widthAnchor.constraint(equalToConstant: 20),
            iconView.heightAnchor.constraint(equalToConstant: 20),

            label.leadingAnchor.constraint(equalTo: iconView.trailingAnchor, constant: 8),
            label.trailingAnchor.constraint(equalTo: toastView.trailingAnchor, constant: -12),
            label.topAnchor.constraint(equalTo: toastView.topAnchor, constant: 10),
            label.bottomAnchor.constraint(equalTo: toastView.bottomAnchor, constant: -10),
        ])

        container.layoutIfNeeded()

        toastView.alpha = 0
        toastView.transform = CGAffineTransform(translationX: 0, y: -40)

        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(type == .success ? .success : .error)

        UIView.animate(
            withDuration: 0.35,
            delay: 0,
            usingSpringWithDamping: 0.8,
            initialSpringVelocity: 0.5,
            options: [.curveEaseOut]
        ) {
            toastView.alpha = 1
            toastView.transform = .identity
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
            UIView.animate(
                withDuration: 0.3,
                delay: 0,
                options: [.curveEaseIn]
            ) {
                toastView.alpha = 0
                toastView.transform = CGAffineTransform(translationX: 0, y: -20)
            } completion: { _ in
                toastView.removeFromSuperview()
            }
        }
    }

    private func toastContainerView() -> UIView {
        if let navView = navigationController?.view {
            return navView
        }
        if let tabView = tabBarController?.view {
            return tabView
        }
        return view
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

extension UIButton {
    func applyFilledStyle(
        title: String,
        systemImageName: String? = nil,
        baseBackgroundColor: UIColor = .systemBlue,
        baseForegroundColor: UIColor = .white,
        contentInsets: NSDirectionalEdgeInsets = .init(top: 12, leading: 12, bottom: 12, trailing: 12),
        cornerStyle: UIButton.Configuration.CornerStyle = .large,
        addShadow: Bool = true
    ) {
        var config = UIButton.Configuration.filled()
        config.title = title
        config.cornerStyle = cornerStyle
        config.baseBackgroundColor = baseBackgroundColor
        config.baseForegroundColor = baseForegroundColor
        config.contentInsets = contentInsets

        if let systemImageName {
            config.image = UIImage(systemName: systemImageName)
            config.imagePlacement = .leading
            config.imagePadding = 8
        }

        self.configuration = config

        if addShadow {
            layer.shadowColor = UIColor.black.withAlphaComponent(0.15).cgColor
            layer.shadowOpacity = 1
            layer.shadowRadius = 6
            layer.shadowOffset = CGSize(width: 0, height: 3)
        } else {
            layer.shadowOpacity = 0
        }
    }

    static func makeIconButton(
        systemName: String,
        pointSize: CGFloat = 16,
        weight: UIImage.SymbolWeight = .medium,
        tintColor: UIColor = .darkGray,
        contentInsets: UIEdgeInsets = .init(top: 6, left: 6, bottom: 6, right: 6),
        backgroundColor: UIColor = .clear,
        cornerRadius: CGFloat = 0
    ) -> UIButton {
        let btn = UIButton(type: .system)
        let config = UIImage.SymbolConfiguration(pointSize: pointSize, weight: weight)
        let image = UIImage(systemName: systemName)?.withConfiguration(config)
        btn.setImage(image, for: .normal)
        btn.tintColor = tintColor
        btn.contentEdgeInsets = contentInsets
        btn.backgroundColor = backgroundColor
        if cornerRadius > 0 {
            btn.layer.cornerRadius = cornerRadius
            btn.clipsToBounds = true
        }
        return btn
    }

    static func makeTextButton(
        title: String = "",
        titleColor: UIColor = .darkGray,
        font: UIFont = .systemFont(ofSize: 15),
        alignment: UIControl.ContentHorizontalAlignment = .center
    ) -> UIButton {
        let btn = UIButton(type: .system)
        btn.setTitle(title, for: .normal)
        btn.setTitleColor(titleColor, for: .normal)
        btn.titleLabel?.font = font
        btn.contentHorizontalAlignment = alignment
        return btn
    }
}

