//
//  ProfileViewController.swift
//  MemeGenerator
//
//  Created by Emil Maharramov on 19.11.25.
//

import UIKit
import SnapKit

final class ProfileViewController: UIViewController {

    private let avatarView: UIImageView = {
        let iv = UIImageView()
        iv.backgroundColor = .systemGray5
        iv.layer.cornerRadius = 32
        iv.layer.masksToBounds = true
        iv.contentMode = .scaleAspectFill
        return iv
    }()

    private let nameLabel: UILabel = {
        let lbl = UILabel()
        lbl.font = .systemFont(ofSize: 20, weight: .semibold)
        lbl.text = "Meme Master"
        return lbl
    }()

    private let emailLabel: UILabel = {
        let lbl = UILabel()
        lbl.font = .systemFont(ofSize: 14)
        lbl.textColor = .secondaryLabel
        lbl.text = "user@example.com"
        return lbl
    }()

    private let tableView: UITableView = {
        let tv = UITableView(frame: .zero, style: .insetGrouped)
        tv.isScrollEnabled = true
        return tv
    }()

    private enum Row: Int, CaseIterable {
        case myMemes
        case saved
        case premium
        case settings

        var title: String {
            switch self {
            case .myMemes: return "My Memes"
            case .saved: return "Saved Memes"
            case .premium: return "Go Premium"
            case .settings: return "Settings"
            }
        }

        var icon: String {
            switch self {
            case .myMemes: return "photo.on.rectangle"
            case .saved: return "bookmark"
            case .premium: return "star.fill"
            case .settings: return "gearshape"
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = "Profile"

        setupHeader()
        setupTable()
    }

    private func setupHeader() {
        let headerView = UIView()
        view.addSubview(headerView)
        headerView.addSubview(avatarView)
        headerView.addSubview(nameLabel)
        headerView.addSubview(emailLabel)

        headerView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(12)
            $0.leading.trailing.equalToSuperview().inset(16)
        }

        avatarView.snp.makeConstraints {
            $0.top.leading.bottom.equalToSuperview()
            $0.width.height.equalTo(64)
        }

        nameLabel.snp.makeConstraints {
            $0.top.equalTo(avatarView.snp.top).offset(4)
            $0.leading.equalTo(avatarView.snp.trailing).offset(12)
            $0.trailing.equalToSuperview()
        }

        emailLabel.snp.makeConstraints {
            $0.top.equalTo(nameLabel.snp.bottom).offset(4)
            $0.leading.trailing.equalTo(nameLabel)
            $0.bottom.equalToSuperview()
        }

        view.addSubview(tableView)
        tableView.snp.makeConstraints {
            $0.top.equalTo(headerView.snp.bottom).offset(16)
            $0.leading.trailing.bottom.equalTo(view.safeAreaLayoutGuide)
        }
    }

    private func setupTable() {
        tableView.dataSource = self
        tableView.delegate = self
    }
}

extension ProfileViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        Row.allCases.count
    }

    func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath
    ) -> UITableViewCell {
        let cell = UITableViewCell(style: .default, reuseIdentifier: nil)
        let row = Row(rawValue: indexPath.row)!
        cell.textLabel?.text = row.title
        cell.imageView?.image = UIImage(systemName: row.icon)
        cell.accessoryType = .disclosureIndicator

        if row == .premium {
            cell.textLabel?.textColor = .systemYellow
        }

        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        guard let row = Row(rawValue: indexPath.row) else { return }

        switch row {
        case .myMemes:
            // push MyMemesController
            break
        case .saved:
            // push SavedMemesController
            break
        case .premium:
            // push PremiumPaywallController
            break
        case .settings:
            // push SettingsController
            break
        }
    }
}
