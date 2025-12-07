//
//  CreateViewController.swift
//  MemeGenerator
//
//  Created by Emil Maharramov on 19.11.25.
//

import UIKit
import SnapKit

final class CreateViewController: BaseController<BaseViewModel> {

    private weak var router: CreateRouting?

    private let segmentedBackgroundView: UIView = {
        let view = UIView()
        view.backgroundColor = Palette.mgCard
        view.layer.cornerRadius = 20
        view.layer.masksToBounds = true
        view.layer.borderWidth = 1
        view.layer.borderColor = Palette.mgCardStroke.cgColor
        return view
    }()

    private let segmentedControl: UISegmentedControl = {
        let items = ["AI Meme", "AI + Template", "Custom"]
        let sc = UISegmentedControl(items: items)
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

        return sc
    }()

    private let containerView: UIView = {
        let v = UIView()
        v.backgroundColor = .clear
        return v
    }()

    private var currentVC: UIViewController?
    private var childCache: [Int: UIViewController] = [:]

    init(router: CreateRouting) {
        self.router = router
        super.init(viewModel: BaseViewModel())
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = Palette.mgBackground
        navigationItem.title = "Create"

        setupLayout()

        segmentedControl.addTarget(
            self,
            action: #selector(modeChanged),
            for: .valueChanged
        )

        showSegment(index: 0)
    }

    private func setupLayout() {
        view.addSubview(segmentedBackgroundView)
        segmentedBackgroundView.addSubview(segmentedControl)
        view.addSubview(containerView)

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
        guard let vc = viewControllerForSegment(index: index) else { return }
        switchTo(vc: vc)
    }

    private func viewControllerForSegment(index: Int) -> UIViewController? {
        if let cached = childCache[index] {
            return cached
        }

        guard let router = router else { return nil }

        let vc: UIViewController
        switch index {
        case 0:
            vc = router.makeAIMeme()
        case 1:
            vc = router.makeAIWithTemplate()
        case 2:
            vc = router.makeCustomMeme()
        default:
            return nil
        }

        childCache[index] = vc
        return vc
    }

    private func switchTo(vc: UIViewController) {
        if let current = currentVC {
            current.willMove(toParent: nil)
            current.view.removeFromSuperview()
            current.removeFromParent()
        }

        addChild(vc)
        containerView.addSubview(vc.view)

        vc.view.translatesAutoresizingMaskIntoConstraints = false
        vc.view.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        vc.didMove(toParent: self)
        vc.view.layoutIfNeeded()

        currentVC = vc
    }
}
