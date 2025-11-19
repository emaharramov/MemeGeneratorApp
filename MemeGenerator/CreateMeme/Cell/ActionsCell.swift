//
//  ActionsCell.swift
//  MemeGenerator
//
//  Created by Emil Maharramov on 19.11.25.
//

import UIKit
import SnapKit

final class ActionsCell: UICollectionViewCell {
    static let id = "ActionsCell"

    var onGenerate = UIButton(type: .system)
    var onNewButton = UIButton(type: .system)

    override init(frame: CGRect) {
        super.init(frame: frame)

        onGenerate.setTitle("Generate", for: .normal)
        onGenerate.backgroundColor = .systemYellow
        onGenerate.layer.cornerRadius = 12

        onNewButton.setTitle("Create New", for: .normal)
        onNewButton.setTitleColor(.red, for: .normal)

        let stack = UIStackView(arrangedSubviews: [onGenerate, onNewButton])
        stack.axis = .horizontal
        stack.distribution = .fillEqually
        stack.spacing = 12

        contentView.addSubview(stack)
        stack.snp.makeConstraints { $0.edges.equalToSuperview() }
    }

    required init?(coder: NSCoder) { fatalError() }
}

