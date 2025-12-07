//
//  ManageSubscriptionVC.swift
//  MemeGenerator
//
//  Created by Emil Maharramov on 28.11.25.
//

import UIKit
import SnapKit

final class ManageSubscriptionVC: BaseController<ManageSubscriptionVM> {

    private let label = UILabel()

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.title = "Manage Subscription"
        view.backgroundColor = Palette.mgBackground

        label.text = "Manage Subscription screen\n(coming soon)"
        label.numberOfLines = 0
        label.textAlignment = .center
        label.textColor = Palette.mgTextSecondary
        label.font = .systemFont(ofSize: 16, weight: .medium)

        view.addSubview(label)
        label.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.leading.trailing.equalToSuperview().inset(24)
        }
    }
}
