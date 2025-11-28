//
//  HelpFeedbackVC.swift
//  MemeGenerator
//
//  Created by Emil Maharramov on 28.11.25.
//

import UIKit
import SnapKit

final class HelpFeedbackVC: BaseController<HelpFeedbackVM> {

    private let label = UILabel()

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Help & Feedback"
        view.backgroundColor = .systemBackground

        label.text = "Help & Feedback screen\n(coming soon)"
        label.numberOfLines = 0
        label.textAlignment = .center
        label.textColor = .secondaryLabel

        view.addSubview(label)
        label.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.leading.trailing.equalToSuperview().inset(24)
        }
    }
}
