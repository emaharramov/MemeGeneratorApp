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

    var onDownloadTapped: ((UIImage?) -> Void)?
    var onSaveTapped: ((MemesTemplate) -> Void)?

    private var currentTemplate: MemesTemplate?

    // MARK: - Views

    private let cardView: UIView = {
        let v = UIView()
        v.backgroundColor = .mgCard
        v.layer.cornerRadius = 26
        v.layer.masksToBounds = false
        v.layer.shadowColor = UIColor.black.cgColor
        v.layer.shadowOpacity = 0.45
        v.layer.shadowRadius = 22
        v.layer.shadowOffset = CGSize(width: 0, height: 14)
        v.layer.borderWidth = 1
        v.layer.borderColor = UIColor.mgCardStroke.cgColor
        return v
    }()

    private let memeImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleToFill
        iv.clipsToBounds = true
        iv.layer.cornerRadius = 20
        iv.layer.maskedCorners = [
            .layerMinXMinYCorner,
            .layerMaxXMinYCorner
        ]
        iv.backgroundColor = UIColor.black.withAlphaComponent(0.25)
        return iv
    }()

    private let titleLabel: UILabel = {
        let lbl = UILabel()
        lbl.font = .systemFont(ofSize: 15, weight: .semibold)
        lbl.textColor = .mgTextPrimary
        lbl.numberOfLines = 0
        return lbl
    }()

    private let subtitleLabel: UILabel = {
        let lbl = UILabel()
        lbl.font = .systemFont(ofSize: 12, weight: .regular)
        lbl.textColor = .mgTextSecondary
        lbl.numberOfLines = 1
        return lbl
    }()

    private let bottomDivider: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor.white.withAlphaComponent(0.06)
        return v
    }()

    private let downloadButton: UIButton = {
        let btn = UIButton(type: .system)
        let image = UIImage(systemName: "square.and.arrow.down")
        btn.setImage(image, for: .normal)
        btn.tintColor = .mgAccent
        btn.backgroundColor = UIColor.white.withAlphaComponent(0.06)
        btn.layer.cornerRadius = 16
        btn.contentEdgeInsets = UIEdgeInsets(top: 6, left: 6, bottom: 6, right: 6)
        return btn
    }()

    private let saveButton: UIButton = {
        let btn = UIButton(type: .system)
        let image = UIImage(systemName: "bookmark")
        btn.setImage(image, for: .normal)
        btn.tintColor = .mgAccent
        btn.backgroundColor = UIColor.white.withAlphaComponent(0.06)
        btn.layer.cornerRadius = 16
        btn.contentEdgeInsets = UIEdgeInsets(top: 6, left: 6, bottom: 6, right: 6)
        return btn
    }()

    private let bottomStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.alignment = .center
        stack.spacing = 12
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

        contentView.addSubview(cardView)
        cardView.addSubview(memeImageView)
        cardView.addSubview(titleLabel)
        cardView.addSubview(subtitleLabel)
        cardView.addSubview(bottomDivider)
        cardView.addSubview(bottomStack)

        bottomStack.addArrangedSubview(UIView())
        bottomStack.addArrangedSubview(downloadButton)
        bottomStack.addArrangedSubview(saveButton)

        downloadButton.addTarget(self,
                                 action: #selector(handleDownload),
                                 for: .touchUpInside)
        saveButton.addTarget(self,
                             action: #selector(handleSave),
                             for: .touchUpInside)
    }

    private func configureConstraints() {
        cardView.snp.makeConstraints {
            $0.edges.equalToSuperview().inset(UIEdgeInsets(top: 4, left: 16, bottom: 4, right: 16))
        }

        memeImageView.snp.makeConstraints {
            $0.top.equalToSuperview() // .offset(12)
            $0.left.right.equalToSuperview() // .inset(12)
            // feeddəki böyük meme kartına oxşar olsun deyə bir az hündür
            $0.height.equalTo(memeImageView.snp.width).multipliedBy(1.05)
        }

        titleLabel.snp.makeConstraints {
            $0.top.equalTo(memeImageView.snp.bottom).offset(12)
            $0.left.right.equalToSuperview().inset(16)
        }

        subtitleLabel.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(4)
            $0.left.right.equalToSuperview().inset(16)
        }

        bottomDivider.snp.makeConstraints {
            $0.top.equalTo(subtitleLabel.snp.bottom).offset(12)
            $0.left.right.equalToSuperview()
            $0.height.equalTo(1 / UIScreen.main.scale)
        }

        bottomStack.snp.makeConstraints {
            $0.top.equalTo(bottomDivider.snp.bottom).offset(10)
            $0.left.right.equalToSuperview().inset(16)
            $0.bottom.equalToSuperview().inset(12)
        }

        downloadButton.snp.makeConstraints {
            $0.width.height.equalTo(32)
        }

        saveButton.snp.makeConstraints {
            $0.width.height.equalTo(32)
        }
    }

    // MARK: - Reuse

    override func prepareForReuse() {
        super.prepareForReuse()
        memeImageView.image = nil
        titleLabel.text = nil
        subtitleLabel.text = nil
        currentTemplate = nil
    }

    // MARK: - Configure

    func configure(template: MemesTemplate) {
        currentTemplate = template

        memeImageView.loadImage(template.imageURL ?? "")

        let top = (template.topText ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        let bottom = (template.bottomText ?? "").trimmingCharacters(in: .whitespacesAndNewlines)

        if !top.isEmpty || !bottom.isEmpty {
            titleLabel.text = [top, bottom]
                .joined(separator: " ")
                .trimmingCharacters(in: .whitespacesAndNewlines)
        } else {
            titleLabel.text = "Awesome meme from AI"
        }

        let author = (template.username ?? "unknown").trimmingCharacters(in: .whitespacesAndNewlines)
        let time = template.createdAt?.timeAgoString() ?? ""
        subtitleLabel.text = "by @\(author) • \(time)"
    }

    // MARK: - Actions

    @objc private func handleDownload() {
        onDownloadTapped?(memeImageView.image)
    }

    @objc private func handleSave() {
        guard let template = currentTemplate else { return }
        onSaveTapped?(template)
    }
}
