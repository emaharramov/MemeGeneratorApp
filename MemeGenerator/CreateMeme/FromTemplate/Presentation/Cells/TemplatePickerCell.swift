//
//  TemplatePickerCell.swift
//  MemeGenerator
//
//  Created by Emil Maharramov on 01.12.25.
//

import UIKit
import SnapKit

final class TemplatePickerCell: UICollectionViewCell {
    static let reuseId = String(describing: TemplatePickerCell.self)

    private let imageView = UIImageView()
    private let titleLabel = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        contentView.backgroundColor = .mgCard
        contentView.layer.cornerRadius = 16
        contentView.layer.masksToBounds = true
        contentView.layer.borderWidth = 1
        contentView.layer.borderColor = UIColor.mgCardStroke.cgColor

        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true

        titleLabel.font = .systemFont(ofSize: 12, weight: .medium)
        titleLabel.textColor = .mgTextPrimary
        titleLabel.numberOfLines = 0

        contentView.addSubview(imageView)
        contentView.addSubview(titleLabel)

        imageView.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.height.equalTo(imageView.snp.width)
        }

        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(imageView.snp.bottom).offset(4)
            make.leading.trailing.equalToSuperview().inset(6)
            make.bottom.lessThanOrEqualToSuperview().inset(4)
        }
    }

    func configure(with template: TemplateDTO) {
        titleLabel.text = template.name

        MemeService.shared.loadImage(url: template.url) { [weak self] img in
            DispatchQueue.main.async {
                self?.imageView.image = img
            }
        }
    }
}
