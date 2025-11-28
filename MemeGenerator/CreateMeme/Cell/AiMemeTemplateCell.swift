//
//  AiMemeTemplateCell.swift
//  MemeGenerator
//
//  Created by Emil Maharramov on 29.11.25.
//

import UIKit
import SnapKit

final class AIMemeTemplateCell: UICollectionViewCell {
    static let id = "AIMemeTemplateCell"

    let imageView = UIImageView()

    private let selectionOverlay = UIView()
    private let checkmarkImageView = UIImageView()

    override var isSelected: Bool {
        didSet { updateSelectionUI() }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setSelected(_ selected: Bool) {
        isSelected = selected
    }

    // MARK: - UI

    private func setupUI() {
        contentView.backgroundColor = .clear

        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 14
        imageView.clipsToBounds = true

        contentView.addSubview(imageView)
        imageView.snp.makeConstraints { $0.edges.equalToSuperview() }

        // overlay
        selectionOverlay.backgroundColor = UIColor.black.withAlphaComponent(0.35)
        selectionOverlay.layer.cornerRadius = 14
        selectionOverlay.clipsToBounds = true
        selectionOverlay.isHidden = true

        contentView.addSubview(selectionOverlay)
        selectionOverlay.snp.makeConstraints { $0.edges.equalToSuperview() }

        // checkmark
        checkmarkImageView.image = UIImage(systemName: "checkmark.circle.fill")
        checkmarkImageView.tintColor = .systemYellow
        checkmarkImageView.contentMode = .scaleAspectFit

        selectionOverlay.addSubview(checkmarkImageView)
        checkmarkImageView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(32)
        }

        // Shadow / card hissi
        contentView.layer.shadowColor = UIColor.black.withAlphaComponent(0.12).cgColor
        contentView.layer.shadowOpacity = 1
        contentView.layer.shadowRadius = 6
        contentView.layer.shadowOffset = CGSize(width: 0, height: 3)
    }

    private func updateSelectionUI() {
        UIView.animate(withDuration: 0.18) {
            if self.isSelected {
                self.selectionOverlay.isHidden = false
                self.transform = CGAffineTransform(scaleX: 1.03, y: 1.03)
            } else {
                self.selectionOverlay.isHidden = true
                self.transform = .identity
            }
        }
    }
}
