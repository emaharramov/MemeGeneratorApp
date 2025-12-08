//
//  PremiumHeaderCell.swift
//  MemeGenerator
//
//  Created by Emil Maharramov on 30.11.25.
//

import UIKit
import SnapKit

final class PremiumHeaderCell: UITableViewCell {

    static let reuseID = "PremiumHeaderCell"

    private let headerImageView = UIImageView()
    private let titleLabel = UILabel()
    private let subtitleLabel = UILabel()
    private let gradientLayer = CAGradientLayer()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        backgroundColor = .clear
        contentView.backgroundColor = .clear
        setupUI()
    }

    required init?(coder: NSCoder) { fatalError() }

    private func setupUI() {
        headerImageView.layer.cornerRadius = 24
        headerImageView.clipsToBounds = true
        headerImageView.backgroundColor = Palette.mgCardElevated
        headerImageView.contentMode = .scaleAspectFill

        gradientLayer.colors = [
            Palette.mgAccent.withAlphaComponent(0.9).cgColor,
            Palette.mgAccentSoft.withAlphaComponent(0.4).cgColor
        ]
        gradientLayer.startPoint = CGPoint(x: 0, y: 0)
        gradientLayer.endPoint   = CGPoint(x: 1, y: 1)
        headerImageView.layer.insertSublayer(gradientLayer, at: 0)

        let robot = UIImageView(image: UIImage(systemName: "sparkles"))
        robot.tintColor = Palette.mgTextPrimary
        robot.contentMode = .scaleAspectFit
        headerImageView.addSubviews(robot)
        robot.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(80)
        }

        titleLabel.font = .systemFont(ofSize: 26, weight: .bold)
        titleLabel.textColor = Palette.mgTextPrimary
        titleLabel.textAlignment = .center
        titleLabel.numberOfLines = 0

        subtitleLabel.font = .systemFont(ofSize: 15, weight: .regular)
        subtitleLabel.textColor = Palette.mgTextSecondary
        subtitleLabel.textAlignment = .center
        subtitleLabel.numberOfLines = 0

        let stack = UIStackView(arrangedSubviews: [headerImageView, titleLabel, subtitleLabel])
        stack.axis = .vertical
        stack.spacing = 16
        stack.alignment = .fill

        contentView.addSubviews(stack)
        stack.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(4)
            make.bottom.equalToSuperview().inset(4)
            make.leading.trailing.equalToSuperview().inset(20)
        }

        headerImageView.snp.makeConstraints { make in
            make.height.equalTo(240)
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer.frame = headerImageView.bounds
    }

    func configure(title: String, subtitle: String) {
        titleLabel.text = title
        subtitleLabel.text = subtitle
    }
}
