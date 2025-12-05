//
//  AvatarCropOverlayView.swift
//  MemeGenerator
//
//  Created by Emil Maharramov on 05.12.25.
//

import UIKit

final class AvatarCropOverlayView: UIView {

    private(set) var circleRect: CGRect = .zero

    override func layoutSubviews() {
        super.layoutSubviews()

        layer.sublayers?.forEach { $0.removeFromSuperlayer() }

        let inset: CGFloat = 40
        let diameter = min(bounds.width, bounds.height) - inset * 2
        let rect = CGRect(
            x: (bounds.width  - diameter) / 2,
            y: (bounds.height - diameter) / 2,
            width: diameter,
            height: diameter
        )
        circleRect = rect

        let fullPath   = UIBezierPath(rect: bounds)
        let circlePath = UIBezierPath(ovalIn: rect)
        fullPath.append(circlePath)
        fullPath.usesEvenOddFillRule = true

        let dimLayer = CAShapeLayer()
        dimLayer.path = fullPath.cgPath
        dimLayer.fillRule = .evenOdd
        dimLayer.fillColor = UIColor.black.withAlphaComponent(0.6).cgColor

        let borderLayer = CAShapeLayer()
        borderLayer.path = circlePath.cgPath
        borderLayer.strokeColor = UIColor.white.cgColor
        borderLayer.fillColor = UIColor.clear.cgColor
        borderLayer.lineWidth = 2

        layer.addSublayer(dimLayer)
        layer.addSublayer(borderLayer)
    }
}
