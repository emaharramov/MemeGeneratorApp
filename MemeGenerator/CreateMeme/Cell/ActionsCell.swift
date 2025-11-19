//
//  ActionsCell.swift
//  MemeGenerator
//
//  Created by Emil Maharramov on 19.11.25.
//

import UIKit
import SnapKit

final class ActionsCell: UICollectionViewCell {
    static let id = "ActionsCell"

    // Controller bunları istifadə etdiyi üçün adları saxlayıram
    let onGenerate = UIButton(type: .system)
    let onNewButton = UIButton(type: .system)

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Setup

    private func setupUI() {
        contentView.backgroundColor = .clear

        configure(button: onGenerate, title: "Generate", systemImage: "sparkles")
        configure(button: onNewButton, title: "Create New", systemImage: "arrow.clockwise")

        let stack = UIStackView(arrangedSubviews: [onGenerate, onNewButton])
        stack.axis = .horizontal
        stack.distribution = .fillEqually
        stack.spacing = 12

        contentView.addSubview(stack)
        stack.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }

    private func configure(button: UIButton, title: String, systemImage: String) {
        // Modern configuration
        var config = UIButton.Configuration.filled()
        config.title = title
        config.image = UIImage(systemName: systemImage)
        config.imagePlacement = .leading
        config.imagePadding = 6
        config.baseBackgroundColor = .systemYellow
        config.baseForegroundColor = .black
        config.cornerStyle = .large
        config.contentInsets = NSDirectionalEdgeInsets(
            top: 10, leading: 10, bottom: 10, trailing: 10
        )
        button.configuration = config

        button.layer.shadowColor = UIColor.black.withAlphaComponent(0.15).cgColor
        button.layer.shadowOpacity = 1
        button.layer.shadowRadius = 6
        button.layer.shadowOffset = CGSize(width: 0, height: 3)

        button.adjustsImageWhenHighlighted = false

        addTapAnimation(to: button)
    }

    // MARK: - Tap animation

    private func addTapAnimation(to button: UIButton) {
        button.addTarget(self,
                         action: #selector(handleTouchDown(_:)),
                         for: [.touchDown, .touchDragEnter])
        button.addTarget(self,
                         action: #selector(handleTouchUp(_:)),
                         for: [.touchUpInside, .touchCancel, .touchDragExit])
    }

    @objc private func handleTouchDown(_ sender: UIButton) {
        UIView.animate(withDuration: 0.08) {
            sender.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
        }
    }

    @objc private func handleTouchUp(_ sender: UIButton) {
        UIView.animate(
            withDuration: 0.18,
            delay: 0,
            usingSpringWithDamping: 0.7,
            initialSpringVelocity: 0.8,
            options: [.allowUserInteraction, .beginFromCurrentState],
            animations: {
                sender.transform = .identity
            },
            completion: nil
        )
    }
}
