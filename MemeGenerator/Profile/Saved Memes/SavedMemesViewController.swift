//
//  SavedMemesViewController.swift
//  MemeGenerator
//
//  Created by Emil Maharramov on 28.11.25.
//

import UIKit
import SnapKit

final class SavedMemesViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = "Saved Memes"

        let label = UILabel()
        label.text = "Saved Memes – coming soon"
        label.textColor = .secondaryLabel
        label.textAlignment = .center

        view.addSubview(label)
        label.snp.makeConstraints { $0.center.equalToSuperview() }
    }
}

