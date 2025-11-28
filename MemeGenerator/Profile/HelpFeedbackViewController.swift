//
//  HelpFeedbackViewController.swift
//  MemeGenerator
//
//  Created by Emil Maharramov on 28.11.25.
//

import UIKit
import SnapKit

final class HelpFeedbackViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = "Help & Feedback"

        let label = UILabel()
        label.text = "For help or feedback, contact us at\nsupport@memegenerator.app"
        label.numberOfLines = 0
        label.textColor = .secondaryLabel
        label.textAlignment = .center

        view.addSubview(label)
        label.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.leading.trailing.equalToSuperview().inset(24)
        }
    }
}
