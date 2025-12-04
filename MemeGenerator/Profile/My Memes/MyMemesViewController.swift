//
//  MyMemesViewController.swift
//  MemeGenerator
//
//  Created by Emil Maharramov on 28.11.25.
//

import UIKit
import SnapKit

protocol ProfileCountsDelegate: AnyObject {
    func didUpdateMemesCount(_ count: Int)
    func didUpdateSavedCount(_ count: Int)
}

final class MyMemesViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .mgBackground
        title = "My Memes"

        let label = UILabel()
        label.text = "My Memes – coming soon"
        label.textColor = .secondaryLabel
        label.textAlignment = .center

        view.addSubview(label)
        label.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
    }
}
