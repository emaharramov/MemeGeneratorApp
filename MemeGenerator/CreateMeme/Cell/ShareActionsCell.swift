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

    private let shareView = MemeShareActionsView()

    var onSave: (() -> Void)? {
        didSet { shareView.onSave = onSave }
    }

    var onShare: (() -> Void)? {
        didSet { shareView.onShare = onShare }
    }

    var onRegenerate: (() -> Void)? {
        didSet { shareView.onTryAgain = onRegenerate }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)

        contentView.addSubview(shareView)
        shareView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(8)
        }
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}
