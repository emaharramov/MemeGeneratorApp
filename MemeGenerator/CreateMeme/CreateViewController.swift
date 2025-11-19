//
//  CreateViewController.swift
//  MemeGenerator
//
//  Created by Emil Maharramov on 19.11.25.
//

import UIKit
import SnapKit

final class CreateViewController: UIViewController {

    private let segmentedControl: UISegmentedControl = {
        let sc = UISegmentedControl(items: ["AI", "Upload"])
        sc.selectedSegmentIndex = 0
        return sc
    }()

    private let containerView = UIView()

    // MARK: - Child Controllers
    private lazy var aiVC = AIMemeViewController(userId: AppStorage.shared.userId)
    private lazy var uploadVC = UploadMemeViewController()
    
    // Current VC
    private var currentVC: UIViewController?

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        navigationItem.title = "Create Meme"

        setupLayout()
        segmentedControl.addTarget(self, action: #selector(modeChanged), for: .valueChanged)

        // show default (AI)
        switchTo(vc: aiVC)
    }

    private func setupLayout() {
        view.addSubview(segmentedControl)
        view.addSubview(containerView)

        segmentedControl.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(12)
            $0.leading.trailing.equalToSuperview().inset(16)
        }

        containerView.snp.makeConstraints {
            $0.top.equalTo(segmentedControl.snp.bottom).offset(12)
            $0.leading.trailing.equalToSuperview().inset(0)
            $0.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
        }
    }

    // MARK: - Switching Logic
    @objc private func modeChanged() {
        let index = segmentedControl.selectedSegmentIndex

        switch index {
        case 0: switchTo(vc: aiVC)
        case 1: switchTo(vc: uploadVC)
        default: break
        }
    }

    private func switchTo(vc: UIViewController) {
        // Remove old
        if let current = currentVC {
            current.willMove(toParent: nil)
            current.view.removeFromSuperview()
            current.removeFromParent()
        }

        // Add new
        addChild(vc)
        containerView.addSubview(vc.view)

        vc.view.translatesAutoresizingMaskIntoConstraints = false

        vc.view.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        vc.didMove(toParent: self)
        vc.view.setNeedsLayout()
        vc.view.layoutIfNeeded()

        currentVC = vc
    }

}
