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
        let sc = UISegmentedControl(items: ["AI", "Upload", "Templates"])
        sc.selectedSegmentIndex = 0
        return sc
    }()

    private let containerView = UIView()

    // Placeholder subviews
    private let aiView = UIView()
    private let uploadView = UIView()
    private let templatesView = UIView()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = "Create"

        setupSubviews()
        setupConstraints()
        setupContentViews()
        updateVisibleMode(index: 0)

        segmentedControl.addTarget(self, action: #selector(modeChanged), for: .valueChanged)
    }

    private func setupSubviews() {
        [segmentedControl, containerView].forEach(view.addSubview)
    }

    private func setupConstraints() {
        segmentedControl.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(12)
            $0.leading.trailing.equalToSuperview().inset(16)
        }

        containerView.snp.makeConstraints {
            $0.top.equalTo(segmentedControl.snp.bottom).offset(12)
            $0.leading.trailing.bottom.equalTo(view.safeAreaLayoutGuide).inset(16)
        }
    }

    private func setupContentViews() {
        // AI View – burda textfield + generate button olacaq
        aiView.backgroundColor = .systemGray6
        let aiLabel = UILabel()
        aiLabel.text = "AI Meme Generator (prompt + GPT + Imgflip)"
        aiLabel.numberOfLines = 0
        aiLabel.textAlignment = .center
        aiView.addSubview(aiLabel)
        aiLabel.snp.makeConstraints { $0.edges.equalToSuperview().inset(16) }

        // Upload View – lokal şəkil edit
        uploadView.backgroundColor = .systemGray6
        let uploadLabel = UILabel()
        uploadLabel.text = "Upload image from gallery and edit locally"
        uploadLabel.numberOfLines = 0
        uploadLabel.textAlignment = .center
        uploadView.addSubview(uploadLabel)
        uploadLabel.snp.makeConstraints { $0.edges.equalToSuperview().inset(16) }

        // Templates View – Imgflip templates
        templatesView.backgroundColor = .systemGray6
        let templatesLabel = UILabel()
        templatesLabel.text = "Choose a template from Imgflip list"
        templatesLabel.numberOfLines = 0
        templatesLabel.textAlignment = .center
        templatesView.addSubview(templatesLabel)
        templatesLabel.snp.makeConstraints { $0.edges.equalToSuperview().inset(16) }

        [aiView, uploadView, templatesView].forEach { sub in
            containerView.addSubview(sub)
            sub.snp.makeConstraints { $0.edges.equalToSuperview() }
        }
    }

    @objc private func modeChanged() {
        updateVisibleMode(index: segmentedControl.selectedSegmentIndex)
    }

    private func updateVisibleMode(index: Int) {
        aiView.isHidden = index != 0
        uploadView.isHidden = index != 1
        templatesView.isHidden = index != 2
    }
}
