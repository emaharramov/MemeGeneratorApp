//
//  AIMemeTemplateCell.swift
//  MemeGenerator
//
//  Created by Emil Maharramov on 19.11.25.
//

import UIKit
import SnapKit

final class AIMemeTemplateCell: UICollectionViewCell {
    static let id = "AIMemeTemplateCell"

    let imageView = UIImageView()
    private let borderView = UIView()

    override var isSelected: Bool {
        didSet { updateSelectionUI() }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)

        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 12
        imageView.clipsToBounds = true

        borderView.layer.cornerRadius = 12
        borderView.layer.borderWidth = 0
        borderView.layer.borderColor = UIColor.clear.cgColor
        borderView.backgroundColor = .clear

        contentView.addSubview(borderView)
        contentView.addSubview(imageView)

        borderView.snp.makeConstraints { $0.edges.equalToSuperview() }
        imageView.snp.makeConstraints { $0.edges.equalToSuperview() }
    }

    private func updateSelectionUI() {
        UIView.animate(withDuration: 0.2) {
            if self.isSelected {
                self.borderView.layer.borderWidth = 3
                self.borderView.layer.borderColor = UIColor.systemYellow.cgColor
                self.borderView.backgroundColor = UIColor.systemYellow.withAlphaComponent(0.15)
                self.transform = CGAffineTransform(scaleX: 1.03, y: 1.03)
            } else {
                self.borderView.layer.borderWidth = 0
                self.borderView.layer.borderColor = UIColor.clear.cgColor
                self.borderView.backgroundColor = .clear
                self.transform = .identity
            }
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
