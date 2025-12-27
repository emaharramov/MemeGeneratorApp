//
//  PaddedLabel.swift
//  MemeGenerator
//
//  Created by Emil Maharramov on 27.12.25.
//

import UIKit

final class PaddedLabel: UILabel {

    var padding: UIEdgeInsets

    init(padding: UIEdgeInsets = UIEdgeInsets(top: 4, left: 8, bottom: 4, right: 8)) {
        self.padding = padding
        super.init(frame: .zero)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func drawText(in rect: CGRect) {
        super.drawText(in: rect.inset(by: padding))
    }

    override var intrinsicContentSize: CGSize {
        let size = super.intrinsicContentSize
        return CGSize(
            width: size.width + padding.left + padding.right,
            height: size.height + padding.top + padding.bottom
        )
    }

    func setPadding(_ padding: UIEdgeInsets) {
        self.padding = padding
        invalidateIntrinsicContentSize()
        setNeedsDisplay()
    }
}
