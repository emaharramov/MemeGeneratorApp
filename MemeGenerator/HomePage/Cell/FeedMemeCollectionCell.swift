//
//  FeedMemeCollectionCell.swift
//  MemeGenerator
//
//  Created by Emil Maharramov on 24.11.25.
//

import UIKit
import SnapKit

final class FeedMemeCollectionCell: UICollectionViewCell {
    static let reuseId = "FeedMemeCollectionCell"

    // MARK: - Subviews

    private let cardView: UIView = {
        let v = UIView()
        v.backgroundColor = .systemBackground
        v.layer.cornerRadius = 18
        v.layer.masksToBounds = false
        v.layer.shadowColor = UIColor.black.cgColor
        v.layer.shadowOpacity = 0.06
        v.layer.shadowRadius = 10
        v.layer.shadowOffset = CGSize(width: 0, height: 4)
        return v
    }()

    private let avatarView: UIImageView = {
        let iv = UIImageView()
        iv.layer.cornerRadius = 16
        iv.clipsToBounds = true
        iv.contentMode = .scaleAspectFill
        iv.tintColor = .systemGray3
        iv.image = UIImage(systemName: "person.circle.fill")
        iv.backgroundColor = .clear
        return iv
    }()

    private let usernameLabel: UILabel = {
        let lbl = UILabel()
        lbl.font = .systemFont(ofSize: 14, weight: .semibold)
        lbl.textColor = .label
        lbl.numberOfLines = 1
        return lbl
    }()

    private let timeLabel: UILabel = {
        let lbl = UILabel()
        lbl.font = .systemFont(ofSize: 12, weight: .regular)
        lbl.textColor = .secondaryLabel
        return lbl
    }()

    private let headerStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.alignment = .center
        stack.spacing = 10
        return stack
    }()

    private let nameTimeStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 2
        return stack
    }()

    private let memeImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleToFill
        iv.clipsToBounds = true
        iv.layer.cornerRadius = 16
        iv.backgroundColor = .secondarySystemBackground
        return iv
    }()

    private let titleLabel: UILabel = {
        let lbl = UILabel()
        lbl.font = .systemFont(ofSize: 15, weight: .semibold)
        lbl.textColor = UIColor.label.withAlphaComponent(0.8)
        lbl.numberOfLines = 0
        return lbl
    }()
    
    private let likeButton = UIButton.makeIconButton(
        systemName: "hand.thumbsup.fill"
    )

    private let shareButton = UIButton.makeIconButton(
        systemName: "square.and.arrow.up"
    )
    
    private let actionsStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.alignment = .center
        stack.spacing = 16
        return stack
    }()

    // MARK: - Init

    override init(frame: CGRect) {
        super.init(frame: frame)
        configureUI()
        configureConstraints()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Setup

    private func configureUI() {
        contentView.backgroundColor = .clear

        // Hierarchy
        contentView.addSubview(cardView)

        cardView.addSubview(headerStack)
        cardView.addSubview(memeImageView)
        cardView.addSubview(titleLabel)
        cardView.addSubview(actionsStack)

        nameTimeStack.addArrangedSubview(usernameLabel)
        nameTimeStack.addArrangedSubview(timeLabel)

        headerStack.addArrangedSubview(avatarView)
        headerStack.addArrangedSubview(nameTimeStack)
        headerStack.addArrangedSubview(UIView()) // spacer

        actionsStack.addArrangedSubview(likeButton)
        actionsStack.addArrangedSubview(shareButton)
    }

    private func configureConstraints() {
        cardView.snp.makeConstraints {
            $0.edges.equalToSuperview().inset(16)
        }

        avatarView.snp.makeConstraints {
            $0.width.height.equalTo(32)
        }

        headerStack.snp.makeConstraints {
            $0.top.equalToSuperview().inset(12)
            $0.left.right.equalToSuperview().inset(16)
        }

        memeImageView.snp.makeConstraints {
            $0.top.equalTo(headerStack.snp.bottom).offset(12)
            $0.left.right.equalToSuperview().inset(16)
            $0.height.equalTo(memeImageView.snp.width).multipliedBy(0.75)
        }

        titleLabel.snp.makeConstraints {
            $0.top.equalTo(memeImageView.snp.bottom).offset(10)
            $0.left.right.equalToSuperview().inset(16)
        }

        actionsStack.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(12)
            $0.right.equalToSuperview().inset(16)
            $0.bottom.equalToSuperview().inset(10)
        }
    }


    // MARK: - Configure

    func configure(template: MemesTemplate) {
        memeImageView.loadImage(template.imageURL ?? "")

        usernameLabel.text = template.id ?? "Unknown"
        timeLabel.text = template.createdAt?.timeAgoString() ?? ""

        let top = template.topText ?? ""
        let bottom = template.bottomText ?? ""
        titleLabel.text = "\(top) \(bottom)"
    }
}
