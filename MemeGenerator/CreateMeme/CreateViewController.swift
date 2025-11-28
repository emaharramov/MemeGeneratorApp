//
//  CreateViewController.swift
//  MemeGenerator
//
//  Created by Emil Maharramov on 19.11.25.
//

import UIKit
import SnapKit

final class CreateViewController: UIViewController {

    // MARK: - UI

    private let segmentedBackgroundView: UIView = {
        let view = UIView()
        // Açıq bənövşəyi / boz fon (screenshot kimi)
        view.backgroundColor = UIColor(red: 239/255, green: 241/255, blue: 252/255, alpha: 1.0)
        view.layer.cornerRadius = 20
        view.layer.masksToBounds = true
        return view
    }()

    private let segmentedControl: UISegmentedControl = {
        // Title-ları screenshotdakı kimi
        let items = ["AI Meme", "AI + Template", "Custom"]
        let sc = UISegmentedControl(items: items)
        sc.selectedSegmentIndex = 0

        sc.backgroundColor = .clear
        // Seçilən hissə ağ kapsul
        sc.selectedSegmentTintColor = .white

        // Normal state
        let normalAttrs: [NSAttributedString.Key: Any] = [
            .foregroundColor: UIColor.systemIndigo.withAlphaComponent(0.8),
            .font: UIFont.systemFont(ofSize: 14, weight: .medium)
        ]
        // Selected state
        let selectedAttrs: [NSAttributedString.Key: Any] = [
            .foregroundColor: UIColor.black,
            .font: UIFont.systemFont(ofSize: 14, weight: .semibold)
        ]

        sc.setTitleTextAttributes(normalAttrs, for: .normal)
        sc.setTitleTextAttributes(selectedAttrs, for: .selected)

        sc.layer.cornerRadius = 16
        sc.layer.masksToBounds = true

        return sc
    }()

    private let containerView = UIView()

    // MARK: - Child Controllers

    private lazy var aiVC = AIVC(viewModel: AIVM())
    private lazy var fromTemplateVC = FromTemplateVC(userId: AppStorage.shared.userId)
    private lazy var uploadVC = UploadMemeViewController()

    // Current VC
    private var currentVC: UIViewController?

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .systemGroupedBackground
        navigationItem.title = "Create"

        setupLayout()
        segmentedControl.addTarget(self, action: #selector(modeChanged), for: .valueChanged)

        // default – AI Meme
        switchTo(vc: aiVC)
    }

    // MARK: - Layout

    private func setupLayout() {
        view.addSubview(segmentedBackgroundView)
        segmentedBackgroundView.addSubview(segmentedControl)
        view.addSubview(containerView)

        segmentedBackgroundView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(12)
            $0.leading.trailing.equalToSuperview().inset(16)
            $0.height.equalTo(44)
        }

        // İçəridə kiçik inset verək ki, kapsul daha “pill” görünsün
        segmentedControl.snp.makeConstraints {
            $0.edges.equalToSuperview().inset(4)
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
        case 0: switchTo(vc: aiVC)             // AI Meme
        case 1: switchTo(vc: fromTemplateVC)   // AI + Template
        case 2: switchTo(vc: uploadVC)         // Custom / Upload
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
