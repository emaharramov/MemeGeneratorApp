//
//  Extension.swift
//  MemeGenerator
//
//  Created by Emil Maharramov on 18.11.25.
//

import UIKit
import Foundation
import Kingfisher

// MARK: - UIImageView

extension UIImageView {
    func loadImage(_ path: String?) {
        kf.cancelDownloadTask()
        image = nil

        guard
            let path,
            !path.isEmpty
        else { return }

        // Allow strings like "#FFF", "#FFFFFF", "FFF", "https://..."
        if path.lowercased().hasPrefix("http"),
           let url = URL(string: path) {
            kf.setImage(with: url)
        }
    }
}

// MARK: - UIEdgeInsets

extension UIEdgeInsets {
    init(all value: CGFloat) {
        self.init(top: value, left: value, bottom: value, right: value)
    }
}

// MARK: - Date / String timeAgo

extension Date {
    func timeAgoString() -> String {
        let seconds = Int(Date().timeIntervalSince(self))

        let minute = 60
        let hour = 60 * minute
        let day = 24 * hour

        switch seconds {
        case 0..<minute:
            return "\(seconds)s ago"
        case minute..<hour:
            return "\(seconds / minute)m ago"
        case hour..<day:
            return "\(seconds / hour)h ago"
        default:
            return "\(seconds / day)d ago"
        }
    }
}

extension String {
    // expects ISO8601 string with fractional seconds
    func timeAgoString() -> String {
        // static formatter to avoid recreate overhead
        struct Static {
            static let formatter: ISO8601DateFormatter = {
                let f = ISO8601DateFormatter()
                f.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
                return f
            }()
        }

        guard let date = Static.formatter.date(from: self) else {
            return ""
        }
        return date.timeAgoString()
    }
}

// MARK: - CGPoint

extension CGPoint {
    func clamped(in rect: CGRect) -> CGPoint {
        CGPoint(
            x: max(rect.minX, min(rect.maxX, x)),
            y: max(rect.minY, min(rect.maxY, y))
        )
    }
}

// MARK: - UIImage

extension UIImage {
    func resizedToMaxDimension(_ maxDimension: CGFloat) -> UIImage {
        let maxSide = max(size.width, size.height)
        guard maxSide > maxDimension else { return self }

        let scale = maxDimension / maxSide
        let newSize = CGSize(width: size.width * scale,
                             height: size.height * scale)

        let renderer = UIGraphicsImageRenderer(size: newSize)
        return renderer.image { _ in
            draw(in: CGRect(origin: .zero, size: newSize))
        }
    }
}

// MARK: - UIColor (palette + utils)

extension UIColor {
    static let mgBackground      = UIColor(red: 33/255, green: 26/255, blue: 17/255, alpha: 1)
    static let mgLightBackground = UIColor(red: 33/255, green: 26/255, blue: 17/255, alpha: 0.9)
    static let mgCard            = UIColor(red: 45/255, green: 34/255, blue: 23/255, alpha: 1)
    static let mgCardStroke      = UIColor(white: 1, alpha: 0.05)
    static let mgTextPrimary     = UIColor.white
    static let mgPromptColor     = UIColor.white.withAlphaComponent(0.90)
    static let mgTextSecondary   = UIColor.white.withAlphaComponent(0.65)
    static let mgAccent          = UIColor(red: 171/255, green: 120/255, blue: 52/255, alpha: 1)
    static let textFieldTextColor = UIColor(red: 0.70, green: 0.52, blue: 0.26, alpha: 1.0)
    static let cardBg            = UIColor.systemGray6.withAlphaComponent(0.9)

    func isEqualTo(_ other: UIColor) -> Bool {
        isEqual(other)
    }

    convenience init(hexStr: String, colorAlpha: CGFloat = 1) {
        var cleaned = hexStr.trimmingCharacters(in: .whitespacesAndNewlines)
            .lowercased()

        if cleaned.hasPrefix("#") {
            cleaned.removeFirst()
        } else if cleaned.hasPrefix("0x") {
            cleaned.removeFirst(2)
        }

        var rgbHexInt: UInt64 = 0
        Scanner(string: cleaned).scanHexInt64(&rgbHexInt)

        self.init(red: CGFloat((rgbHexInt & 0xff0000) >> 16) / 255,
                  green: CGFloat((rgbHexInt & 0x00ff00) >> 8) / 255,
                  blue: CGFloat(rgbHexInt & 0x0000ff) / 255,
                  alpha: colorAlpha)
    }
}

// MARK: - UIView (FAQ card style)

extension UIView {
    func applyFAQCardStyle() {
        backgroundColor = .mgCard
        layer.cornerRadius = 20
        layer.masksToBounds = false
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.25
        layer.shadowRadius = 18
        layer.shadowOffset = CGSize(width: 0, height: 10)
    }
}

// MARK: - UILabel styles

extension UILabel {
    func applyFAQTitleStyle() {
        textColor = .mgTextPrimary
        font = .systemFont(ofSize: 16, weight: .semibold)
    }

    func applyFAQBodyStyle() {
        textColor = .mgTextSecondary
        font = .systemFont(ofSize: 14, weight: .regular)
    }

    func applyFAQFooterTitleStyle() {
        textColor = .mgTextSecondary
        font = .systemFont(ofSize: 13, weight: .regular)
    }

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

// MARK: - UIButton styles

extension UIButton {
    func applyFAQLinkStyle() {
        setTitleColor(.mgAccent, for: .normal)
        titleLabel?.font = .systemFont(ofSize: 14, weight: .semibold)
    }

    func configureAction(title: String, color: UIColor) {
        setTitle(title, for: .normal)
        backgroundColor = color
        setTitleColor(.white, for: .normal)
        layer.cornerRadius = 14
        titleLabel?.font = .systemFont(ofSize: 15, weight: .semibold)
    }

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

        configuration = config

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

// MARK: - UITextField

extension UITextField {
    func setLeftPaddingPoints(_ amount: CGFloat) {
        let paddingView = UIView(
            frame: CGRect(x: 0, y: 0, width: amount, height: frame.height)
        )
        leftView = paddingView
        leftViewMode = .always
    }

    func setRightPaddingPoints(_ amount: CGFloat) {
        let paddingView = UIView(
            frame: CGRect(x: 0, y: 0, width: amount, height: frame.height)
        )
        rightView = paddingView
        rightViewMode = .always
    }

    func configureField(placeholder: String) {
        self.placeholder = placeholder
        borderStyle = .roundedRect
        backgroundColor = .white
        textAlignment = .center
    }
}

// MARK: - UICollectionView / UITableView dequeue helpers

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

// MARK: - Encodable

extension Encodable {
    func toDictionary() -> [String: Any]? {
        guard let data = try? JSONEncoder().encode(self) else { return nil }
        return (try? JSONSerialization.jsonObject(with: data)) as? [String: Any]
    }
}

// MARK: - UIScrollView

extension UIScrollView {
    func scrollToTop(animated: Bool = true) {
        let topOffset = CGPoint(x: 0, y: -adjustedContentInset.top)
        setContentOffset(topOffset, animated: animated)
    }
}

// MARK: - UIViewController (keyboard + background + toast + meme helpers)

extension UIViewController {

    enum ToastType {
        case success
        case error
        case info
    }

    func setupKeyboardDismissGesture() {
        let tap = UITapGestureRecognizer(
            target: self,
            action: #selector(handleTapToDismissKeyboard)
        )
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }

    @objc private func handleTapToDismissKeyboard() {
        view.endEditing(true)
    }

    func applyDefaultBackground() {
        let isTabBarRoot =
            navigationController?.viewControllers.first === self &&
            tabBarController != nil

        view.backgroundColor = isTabBarRoot
            ? UIColor.systemGroupedBackground
            : UIColor.systemBackground
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
            accentView.backgroundColor = .systemGreen
            iconView.image = UIImage(systemName: "checkmark.circle.fill")
        case .error:
            accentView.backgroundColor = .systemRed
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

// MARK: - BaseController meme helpers

extension BaseController {
    func saveToPhotos(_ image: UIImage?,
                      successMessage: String = "Saved to Photos") {
        guard let image else { return }
        UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
        showToast(message: successMessage, type: .success)
    }

    func shareImage(_ image: UIImage?,
                    from sourceView: UIView? = nil,
                    successMessage: String? = "Meme shared ✌️") {
        guard let image else { return }

        let activityVC = UIActivityViewController(
            activityItems: [image],
            applicationActivities: nil
        )

        if let popover = activityVC.popoverPresentationController {
            popover.sourceView = sourceView ?? view
            popover.sourceRect = sourceView?.bounds
                ?? CGRect(x: view.bounds.midX,
                          y: view.bounds.midY,
                          width: 0,
                          height: 0)
        }

        activityVC.completionWithItemsHandler = { [weak self] _, completed, _, _ in
            guard completed,
                  let self,
                  let successMessage else { return }
            self.showToast(message: successMessage, type: .success)
        }

        present(activityVC, animated: true)
    }

    func validatePrompt(_ rawText: String?,
                        minLength: Int = 3,
                        emptyMessage: String = "Write a funny prompt first 😅",
                        shortMessage: String = "Prompt is too short 🤏") -> String? {
        let text = (rawText ?? "")
            .trimmingCharacters(in: .whitespacesAndNewlines)

        guard !text.isEmpty else {
            showToast(message: emptyMessage, type: .error)
            return nil
        }

        guard text.count >= minLength else {
            showToast(message: shortMessage, type: .error)
            return nil
        }

        return text
    }
}
