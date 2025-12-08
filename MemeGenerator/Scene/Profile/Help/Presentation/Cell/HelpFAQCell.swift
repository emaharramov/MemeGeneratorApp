//
//  HelpFAQCell.swift
//  MemeGenerator
//
//  Created by Emil Maharramov on 06.12.25.
//

import UIKit
import SnapKit

final class HelpFAQCell: UITableViewCell {

    static let reuseID = "HelpFAQCell"

    private let cardView: UIView = {
        let view = UIView()
        return view
    }()

    private let verticalStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.alignment = .fill
        stack.distribution = .fill
        stack.spacing = 8
        return stack
    }()

    private let headerStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.alignment = .center
        stack.distribution = .fill
        stack.spacing = 12
        return stack
    }()

    private let iconContainer: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 18
        view.clipsToBounds = true
        return view
    }()

    private let iconImageView: UIImageView = {
        let iv = UIImageView()
        iv.tintColor = Palette.mgAccent
        iv.contentMode = .scaleAspectFit
        return iv
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        label.applyFAQTitleStyle()
        label.setContentHuggingPriority(.defaultLow, for: .horizontal)
        label.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        return label
    }()

    private let chevronImageView: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(systemName: "chevron.down")
        iv.tintColor = Palette.mgTextSecondary
        iv.contentMode = .scaleAspectFit
        iv.setContentHuggingPriority(.required, for: .horizontal)
        iv.setContentCompressionResistancePriority(.required, for: .horizontal)
        return iv
    }()

    private let bodyStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.alignment = .leading
        stack.distribution = .fill
        stack.spacing = 8
        stack.isHidden = true
        return stack
    }()

    private let bodyLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.applyFAQBodyStyle()
        return label
    }()

    private let linkButton: UIButton = {
        let button = UIButton(type: .system)
        button.contentHorizontalAlignment = .left
        button.applyFAQLinkStyle()
        return button
    }()

    var onLinkTap: (() -> Void)?

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        backgroundColor = .clear
        contentView.backgroundColor = .clear
        selectionStyle = .none

        contentView.addSubviews(cardView)
        cardView.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(8)
            make.bottom.equalToSuperview().inset(8)
            make.leading.trailing.equalToSuperview().inset(16)
        }
        cardView.applyFAQCardStyle()

        cardView.addSubviews(verticalStack)
        verticalStack.snp.makeConstraints { make in
            make.edges.equalToSuperview()
                .inset(UIEdgeInsets(top: 14, left: 16, bottom: 14, right: 16))
        }

        iconContainer.snp.makeConstraints { make in
            make.width.height.equalTo(36)
        }
        iconContainer.setContentHuggingPriority(.required, for: .horizontal)
        iconContainer.setContentCompressionResistancePriority(.required, for: .horizontal)

        iconContainer.addSubviews(iconImageView)
        iconImageView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(20)
        }

        headerStack.addArrangedSubview(iconContainer)
        headerStack.addArrangedSubview(titleLabel)
        headerStack.addArrangedSubview(chevronImageView)

        chevronImageView.snp.makeConstraints { make in
            make.width.height.equalTo(16)
        }

        bodyStack.addArrangedSubview(bodyLabel)
        bodyStack.addArrangedSubview(linkButton)

        verticalStack.addArrangedSubview(headerStack)
        verticalStack.addArrangedSubview(bodyStack)

        linkButton.addTarget(self, action: #selector(handleLinkTap), for: .touchUpInside)
    }

    func configure(with item: HelpFAQItem, expanded: Bool) {
        titleLabel.text = item.title
        bodyLabel.text = item.body

        iconImageView.image = UIImage(systemName: item.iconSystemName)
        iconContainer.backgroundColor = item.iconBackgroundColor

        if let linkTitle = item.linkTitle {
            linkButton.setTitle(linkTitle, for: .normal)
            linkButton.isHidden = false
        } else {
            linkButton.setTitle(nil, for: .normal)
            linkButton.isHidden = true
        }

        setExpanded(expanded, animated: false)
    }

    func setExpanded(_ expanded: Bool, animated: Bool) {
        let changes = {
            self.bodyStack.isHidden = !expanded
            let angle: CGFloat = expanded ? .pi : 0
            self.chevronImageView.transform = CGAffineTransform(rotationAngle: angle)
            self.layoutIfNeeded()
        }

        if animated {
            UIView.animate(withDuration: 0.22,
                           delay: 0,
                           options: [.curveEaseInOut],
                           animations: {
                               changes()
                               self.contentView.layoutIfNeeded()
                           },
                           completion: nil)
        } else {
            changes()
        }
    }

    @objc private func handleLinkTap() {
        onLinkTap?()
    }
}
