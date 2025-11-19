//
//  ShareActionsCell.swift
//  MemeGenerator
//
//  Created by Emil Maharramov on 19.11.25.
//

import UIKit
import SnapKit

final class ShareActionsCell: UICollectionViewCell {

    static let id = "ShareActionsCell"

    var onSave: (() -> Void)?
    var onShare: (() -> Void)?

    private let saveButton = UIButton(type: .system)
    private let shareButton = UIButton(type: .system)

    override init(frame: CGRect) {
        super.init(frame: frame)

        saveButton.setTitle("Save", for: .normal)
        shareButton.setTitle("Share", for: .normal)

        saveButton.addTarget(self, action: #selector(saveTapped), for: .touchUpInside)
        shareButton.addTarget(self, action: #selector(shareTapped), for: .touchUpInside)

        let stack = UIStackView(arrangedSubviews: [saveButton, shareButton])
        stack.axis = .horizontal
        stack.spacing = 12
        stack.distribution = .fillEqually
        contentView.addSubview(stack)

        stack.snp.makeConstraints { $0.edges.equalToSuperview().inset(16) }
    }

    @objc private func saveTapped() {
        onSave?()
    }

    @objc private func shareTapped() {
        onShare?()
    }

    required init?(coder: NSCoder) { fatalError() }
}
