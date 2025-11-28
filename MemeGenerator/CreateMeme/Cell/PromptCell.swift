//
//  PromptCell.swift
//  MemeGenerator
//
//  Created by Emil Maharramov on 19.11.25.
//

import UIKit
import SnapKit

final class PromptCell: UICollectionViewCell {

    static let id = "PromptCell"

    private let promptView: MemePromptView = {
        MemePromptView(
            title: nil,
            subtitle: "Pick a classic template and let AI fill in the text.",
            fieldTitle: "Your Idea",
            placeholder: "e.g., a cat who is a picky eater"
        )
    }()

    var text: String {
        get { promptView.text }
        set { promptView.text = newValue }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)

        contentView.addSubview(promptView)
        promptView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(12)
        }
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}
