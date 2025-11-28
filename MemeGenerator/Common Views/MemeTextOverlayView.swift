//
//  MemeTextOverlayView.swift
//  MemeGenerator
//
//  Created by Emil Maharramov on 19.11.25.
//

import UIKit
import SnapKit
// MARK: - Overlay View (hər text üçün ayrıca)

final class MemeTextOverlayView: UIView {

    let label = UILabel()
    private let closeButton = UIButton(type: .system)

    var onTap: (() -> Void)?
    var onDelete: (() -> Void)?
    var onDragChanged: ((CGPoint) -> Void)?
    var isInEditMode: Bool = false {
        didSet { updateEditMode() }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        setupGestures()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        backgroundColor = .clear

        label.font = .boldSystemFont(ofSize: 26)
        label.textColor = .white
        label.numberOfLines = 0
        label.textAlignment = .center
        label.layer.shadowColor = UIColor.black.cgColor
        label.layer.shadowOpacity = 0.75
        label.layer.shadowRadius = 3
        label.layer.shadowOffset = .zero

        let bubble = UIView()
        bubble.backgroundColor = UIColor.black.withAlphaComponent(0.05)
        bubble.layer.cornerRadius = 8
        bubble.layer.borderWidth = 1
        bubble.layer.borderColor = UIColor.clear.cgColor

        addSubview(bubble)
        bubble.addSubview(label)
        addSubview(closeButton)

        bubble.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(4)
        }
        label.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(UIEdgeInsets(top: 4, left: 6, bottom: 4, right: 6))
        }

        closeButton.setImage(UIImage(systemName: "xmark.circle.fill"), for: .normal)
        closeButton.tintColor = .systemRed
        closeButton.backgroundColor = .white
        closeButton.layer.cornerRadius = 10
        closeButton.addTarget(self, action: #selector(handleDelete), for: .touchUpInside)

        closeButton.snp.makeConstraints { make in
            make.width.height.equalTo(20)
            make.top.equalToSuperview().offset(-2)
            make.trailing.equalToSuperview().offset(2)
        }

        // default olaraq edit mode-da deyil, X gizlidir
        closeButton.isHidden = true
    }

    private func setupGestures() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        addGestureRecognizer(tap)

        let pan = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
        addGestureRecognizer(pan)
    }

    @objc private func handleTap() {
        onTap?()
    }

    @objc private func handleDelete() {
        onDelete?()
    }

    @objc private func handlePan(_ recognizer: UIPanGestureRecognizer) {
        guard let superview = superview else { return }
        let translation = recognizer.translation(in: superview)

        if recognizer.state == .began || recognizer.state == .changed {
            center = CGPoint(x: center.x + translation.x, y: center.y + translation.y)
            recognizer.setTranslation(.zero, in: superview)
        } else if recognizer.state == .ended {
            onDragChanged?(center)
        }
    }

    private func updateEditMode() {
        if isInEditMode {
            startWobble()
            closeButton.isHidden = false
        } else {
            stopWobble()
            closeButton.isHidden = true
        }
    }

    private func startWobble() {
        let angle: CGFloat = 0.02
        let animation = CAKeyframeAnimation(keyPath: "transform.rotation")
        animation.values = [-angle, angle]
        animation.autoreverses = true
        animation.duration = 0.12
        animation.repeatCount = .greatestFiniteMagnitude
        layer.add(animation, forKey: "wobble")
    }

    private func stopWobble() {
        layer.removeAnimation(forKey: "wobble")
    }
}
