//
//  CreateViewController.swift
//  MemeGenerator
//
//  Created by Emil Maharramov on 19.11.25.
//

import UIKit
import SnapKit

final class CreateViewController: UIViewController {

    private let segmentedBackgroundView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.white.withAlphaComponent(0.15)
        view.layer.cornerRadius = 20
        view.layer.masksToBounds = true
        return view
    }()

    private let segmentedControl: UISegmentedControl = {
        let sc = UISegmentedControl(items: ["AI", "Upload"])
        sc.selectedSegmentIndex = 0

        // Rənglər
        sc.backgroundColor = .clear
        sc.selectedSegmentTintColor = UIColor(red: 1, green: 0.97, blue: 0.7, alpha: 1)

        let normalAttrs: [NSAttributedString.Key: Any] = [
            .foregroundColor: UIColor.label.withAlphaComponent(0.8),
            .font: UIFont.systemFont(ofSize: 14, weight: .medium)
        ]
        let selectedAttrs: [NSAttributedString.Key: Any] = [
            .foregroundColor: UIColor.black,
            .font: UIFont.systemFont(ofSize: 14, weight: .semibold)
        ]

        sc.setTitleTextAttributes(normalAttrs, for: .normal)
        sc.setTitleTextAttributes(selectedAttrs, for: .selected)

        sc.layer.cornerRadius = 20
        sc.layer.masksToBounds = true
        return sc
    }()

    private let containerView = UIView()

    // MARK: - Child Controllers

    private lazy var aiVC = AIMemeViewController(userId: AppStorage.shared.userId)
    private lazy var uploadVC = UploadMemeViewController()

    // Current VC
    private var currentVC: UIViewController?

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .systemBackground
        navigationItem.title = "Create Meme"

        setupLayout()
        segmentedControl.addTarget(self, action: #selector(modeChanged), for: .valueChanged)

        // default – AI
        switchTo(vc: aiVC)
    }

    private func setupLayout() {
        view.addSubview(segmentedBackgroundView)
        segmentedBackgroundView.addSubview(segmentedControl)
        view.addSubview(containerView)

        segmentedBackgroundView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(12)
            $0.leading.trailing.equalToSuperview().inset(16)
            $0.height.equalTo(40)
        }

        segmentedControl.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }

        containerView.backgroundColor = .clear
        containerView.snp.makeConstraints {
            $0.top.equalTo(segmentedBackgroundView.snp.bottom).offset(12)
            $0.leading.trailing.equalToSuperview()
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
        // Köhnəni sil
        if let current = currentVC {
            current.willMove(toParent: nil)
            current.view.removeFromSuperview()
            current.removeFromParent()
        }

        // Yenini əlavə et
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
