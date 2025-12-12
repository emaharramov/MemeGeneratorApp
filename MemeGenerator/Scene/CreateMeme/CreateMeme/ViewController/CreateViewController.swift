//
//  CreateViewController.swift
//  MemeGenerator
//
//  Created by Emil Maharramov on 19.11.25.
//

import UIKit
import SnapKit

struct CreateSegmentItem {
    let title: String
    let viewController: UIViewController
}

final class CreateViewController: BaseController<BaseViewModel> {
    private let segments: [CreateSegmentItem]

    private let segmentedBackgroundView: UIView = {
        let view = UIView()
        view.backgroundColor = Palette.mgCard
        view.layer.cornerRadius = 20
        view.layer.masksToBounds = true
        view.layer.borderWidth = 1
        view.layer.borderColor = Palette.mgCardStroke.cgColor
        return view
    }()

    private lazy var segmentedControl: UISegmentedControl = {
        let sc = UISegmentedControl(items: segments.map { $0.title })
        sc.selectedSegmentIndex = 0

        sc.backgroundColor = .clear
        sc.selectedSegmentTintColor = Palette.mgAccent

        let normalAttrs: [NSAttributedString.Key: Any] = [
            .foregroundColor: Palette.mgTextSecondary,
            .font: UIFont.systemFont(ofSize: 14, weight: .medium)
        ]
        let selectedAttrs: [NSAttributedString.Key: Any] = [
            .foregroundColor: UIColor.black,
            .font: UIFont.systemFont(ofSize: 14, weight: .semibold)
        ]

        sc.setTitleTextAttributes(normalAttrs, for: .normal)
        sc.setTitleTextAttributes(selectedAttrs, for: .selected)

        sc.layer.cornerRadius = 16
        sc.layer.masksToBounds = true

        sc.addTarget(self, action: #selector(modeChanged), for: .valueChanged)
        return sc
    }()

    private let containerView: UIView = {
        let v = UIView()
        v.backgroundColor = .clear
        return v
    }()

    private var currentVC: UIViewController?

    private var childCache: [Int: UIViewController] = [:]

    init(
        segments: [CreateSegmentItem]
    ) {
        self.segments = segments
        super.init(viewModel: BaseViewModel())

        // hazır VC-ləri cache-ə yığırıq (optional)
        for (idx, item) in segments.enumerated() {
            childCache[idx] = item.viewController
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = Palette.mgBackground
        navigationItem.title = "Create"

        setupLayout()
        showSegment(index: 0)
    }

    private func setupLayout() {
        view.addSubviews(segmentedBackgroundView)
        segmentedBackgroundView.addSubviews(segmentedControl)
        view.addSubviews(containerView)

        segmentedBackgroundView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(12)
            $0.leading.trailing.equalToSuperview().inset(16)
            $0.height.equalTo(44)
        }

        segmentedControl.snp.makeConstraints {
            $0.edges.equalToSuperview().inset(4)
        }

        containerView.snp.makeConstraints {
            $0.top.equalTo(segmentedBackgroundView.snp.bottom).offset(16)
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
        }
    }

    @objc private func modeChanged() {
        showSegment(index: segmentedControl.selectedSegmentIndex)
    }

    private func showSegment(index: Int) {
        guard segments.indices.contains(index) else { return }

        // cache-dən götürürük (hazır VC)
        let vc = childCache[index] ?? segments[index].viewController
        childCache[index] = vc

        switchTo(vc: vc)
    }

    private func switchTo(vc: UIViewController) {
        guard currentVC !== vc else { return }

        if let current = currentVC {
            current.willMove(toParent: nil)
            current.view.removeFromSuperview()
            current.removeFromParent()
        }

        addChild(vc)
        containerView.addSubviews(vc.view)

        vc.view.snp.makeConstraints { $0.edges.equalToSuperview() }

        vc.didMove(toParent: self)
        currentVC = vc
    }
}
