//
//  OnboardingPageView.swift
//  MemeGenerator
//
//  Created by Emil Maharramov on 06.12.25.
//

import UIKit
import SnapKit

final class OnboardingPageView: UIView {

    private let imageView = UIImageView()
    private let titleLabel = UILabel()
    private let subtitleLabel = UILabel()
    private let descriptionLabel = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }


    func configure(with page: OnboardingModel) {
        imageView.image = UIImage(systemName: page.imageName)
        titleLabel.text = page.title
        subtitleLabel.text = page.subtitle
        descriptionLabel.text = page.description
    }

    private func setupUI() {
        backgroundColor = .clear

        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = Palette.baseBackgroundColor

        titleLabel.font = .systemFont(ofSize: 28, weight: .bold)
        titleLabel.textColor = .white
        titleLabel.textAlignment = .center
        titleLabel.numberOfLines = 0

        subtitleLabel.font = .systemFont(ofSize: 18, weight: .semibold)
        subtitleLabel.textColor = .white
        subtitleLabel.textAlignment = .center
        subtitleLabel.numberOfLines = 0

        descriptionLabel.font = .systemFont(ofSize: 14, weight: .regular)
        descriptionLabel.textColor = UIColor.white.withAlphaComponent(0.8)
        descriptionLabel.textAlignment = .center
        descriptionLabel.numberOfLines = 0

        let stack = UIStackView(arrangedSubviews: [imageView, titleLabel, subtitleLabel, descriptionLabel])
        stack.axis = .vertical
        stack.alignment = .fill
        stack.spacing = 16

        addSubviews(stack)
        stack.translatesAutoresizingMaskIntoConstraints = false
        imageView.translatesAutoresizingMaskIntoConstraints = false

        stack.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(40)
            make.leading.equalToSuperview().offset(24)
            make.trailing.equalToSuperview().inset(24)
            make.bottom.lessThanOrEqualToSuperview()
        }

        imageView.snp.makeConstraints { make in
            make.height.equalToSuperview().multipliedBy(0.4)
        }

    }
}
