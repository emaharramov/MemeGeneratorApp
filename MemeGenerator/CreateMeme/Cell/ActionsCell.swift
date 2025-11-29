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

        configureMainButton()

        onNewButton.isHidden = true
        onNewButton.alpha = 0

        let stack = UIStackView(arrangedSubviews: [onGenerate])
        stack.axis = .vertical
        stack.distribution = .fillEqually

        contentView.addSubview(stack)
        stack.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }

    private func configureMainButton() {
        onGenerate.applyFilledStyle(
            title: "Generate with Template",
            systemImageName: "sparkles"
        )
        addTapAnimation(to: onGenerate)
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
            sender.transform = CGAffineTransform(scaleX: 0.97, y: 0.97)
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
