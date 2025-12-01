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

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        backgroundColor = .clear
        contentView.backgroundColor = .clear
        setupUI()
    }

    required init?(coder: NSCoder) { fatalError() }

    private func setupUI() {
        // Image – gradient + icon placeholder
        headerImageView.layer.cornerRadius = 24
        headerImageView.clipsToBounds = true
        headerImageView.backgroundColor = UIColor.white.withAlphaComponent(0.05)
        headerImageView.contentMode = .scaleAspectFill

        let gradient = CAGradientLayer()
        gradient.colors = [
            UIColor.systemTeal.cgColor,
            UIColor.systemPurple.cgColor
        ]
        gradient.startPoint = CGPoint(x: 0, y: 0)
        gradient.endPoint   = CGPoint(x: 1, y: 1)
        gradient.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width - 40, height: 240)
        headerImageView.layer.insertSublayer(gradient, at: 0)

        let robot = UIImageView(image: UIImage(systemName: "face.smiling"))
        robot.tintColor = .white
        robot.contentMode = .scaleAspectFit
        headerImageView.addSubview(robot)
        robot.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(80)
        }

        titleLabel.font = .systemFont(ofSize: 26, weight: .bold)
        titleLabel.textColor = .mgTextPrimary
        titleLabel.textAlignment = .center
        titleLabel.numberOfLines = 0

        subtitleLabel.font = .systemFont(ofSize: 15, weight: .regular)
        subtitleLabel.textColor = .mgTextSecondary
        subtitleLabel.textAlignment = .center
        subtitleLabel.numberOfLines = 0

        let stack = UIStackView(arrangedSubviews: [headerImageView, titleLabel, subtitleLabel])
        stack.axis = .vertical
        stack.spacing = 16
        stack.alignment = .fill

        contentView.addSubview(stack)
        stack.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(4)
            make.bottom.equalToSuperview().inset(4)
            make.leading.trailing.equalToSuperview().inset(20)
        }

        headerImageView.snp.makeConstraints { make in
            make.height.equalTo(240)
        }
    }

    func configure(title: String, subtitle: String) {
        titleLabel.text = title
        subtitleLabel.text = subtitle
    }
}
