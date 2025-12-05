//
//  LoadingOverlayHelper.swift
//  MemeGenerator
//
//  Created by Emil Maharramov on 06.12.25.
//

import UIKit
import SnapKit

final class LoadingOverlayHelper {

    private var overlay: UIView?
    private let loaderContainer = UIView()
    private let messageLabel = UILabel()
    private var arcsConfigured = false

    func show(on hostView: UIView, message: String?) {
        if overlay == nil {
            buildOverlay(on: hostView)
        }

        updateMessage(message)
        startAnimation()

        guard let overlay else { return }
        hostView.bringSubviewToFront(overlay)

        if overlay.alpha == 0 {
            UIView.animate(withDuration: 0.25,
                           delay: 0,
                           options: [.curveEaseInOut]) {
                overlay.alpha = 1
            }
        }
    }

    func hide() {
        guard let overlay else { return }
        stopAnimation()
        UIView.animate(withDuration: 0.25,
                       delay: 0,
                       options: [.curveEaseInOut]) {
            overlay.alpha = 0
        } completion: { _ in
            overlay.removeFromSuperview()
            self.overlay = nil
            self.arcsConfigured = false
        }
    }

    func updateMessage(_ text: String?) {
        messageLabel.text = text
        messageLabel.isHidden = (text == nil || text?.isEmpty == true)
    }

    private func buildOverlay(on hostView: UIView) {
        let overlay = UIView()
        overlay.backgroundColor = UIColor.black.withAlphaComponent(0.9)
        overlay.alpha = 0
        overlay.isUserInteractionEnabled = true

        hostView.addSubview(overlay)
        overlay.translatesAutoresizingMaskIntoConstraints = false
        overlay.snp.makeConstraints { $0.edges.equalToSuperview() }

        let stack = UIStackView()
        stack.axis = .vertical
        stack.alignment = .center
        stack.spacing = 18
        stack.translatesAutoresizingMaskIntoConstraints = false

        loaderContainer.translatesAutoresizingMaskIntoConstraints = false

        messageLabel.translatesAutoresizingMaskIntoConstraints = false
        messageLabel.textColor = .white
        messageLabel.font = .systemFont(ofSize: 16, weight: .semibold)
        messageLabel.textAlignment = .center
        messageLabel.numberOfLines = 0
        messageLabel.isHidden = true

        overlay.addSubview(stack)
        stack.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.leading.trailing.equalToSuperview().inset(32)
        }

        stack.addArrangedSubview(loaderContainer)
        stack.addArrangedSubview(messageLabel)

        loaderContainer.snp.makeConstraints { make in
            make.width.height.equalTo(56)
        }

        self.overlay = overlay
        overlay.layoutIfNeeded()
        configureArcsIfNeeded()
    }

    private func configureArcsIfNeeded() {
        guard !arcsConfigured else { return }
        arcsConfigured = true

        loaderContainer.layer.sublayers?.forEach { $0.removeFromSuperlayer() }

        let size = min(loaderContainer.bounds.width, loaderContainer.bounds.height)
        let radius = size / 2 - 5
        let center = CGPoint(x: size / 2, y: size / 2)

        func makeArc(startAngle: CGFloat, endAngle: CGFloat) -> CAShapeLayer {
            let layer = CAShapeLayer()
            let path = UIBezierPath(arcCenter: center,
                                    radius: radius,
                                    startAngle: startAngle,
                                    endAngle: endAngle,
                                    clockwise: true)
            layer.path = path.cgPath
            layer.strokeColor = UIColor.systemOrange.cgColor
            layer.lineWidth = 6
            layer.fillColor = UIColor.clear.cgColor
            layer.lineCap = .round
            return layer
        }

        let leftArc = makeArc(startAngle: .pi * 5/6, endAngle: .pi * 9/6)
        let rightArc = makeArc(startAngle: -.pi / 6, endAngle: .pi / 6)

        loaderContainer.layer.addSublayer(leftArc)
        loaderContainer.layer.addSublayer(rightArc)
    }

    private func startAnimation() {
        loaderContainer.layoutIfNeeded()
        configureArcsIfNeeded()

        loaderContainer.layer.removeAllAnimations()

        let wobble = CABasicAnimation(keyPath: "transform.rotation.z")
        wobble.fromValue = -0.25
        wobble.toValue = 0.25
        wobble.duration = 0.45
        wobble.autoreverses = true
        wobble.repeatCount = .infinity
        wobble.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)

        loaderContainer.layer.add(wobble, forKey: "giggle.wobble")
    }

    private func stopAnimation() {
        loaderContainer.layer.removeAllAnimations()
    }
}
