//
//  ProfileViewController.swift
//  MemeGenerator
//
//  Created by Emil Maharramov on 19.11.25.
//

import UIKit
import SnapKit

final class ProfileViewController: UIViewController {

    private enum Section: Int, CaseIterable {
        case header
        case stats
        case menu
    }

    private enum MenuRow: Int, CaseIterable {
        case myMemes
        case savedMemes
        case settings
        case help
        case logout
    }

    private let tableView = UITableView(frame: .zero, style: .plain)

    // Demo data
    private let displayName = "Meme Master"
    private let email = "user@example.com"
    private let memesCount = "142"
    private let savedCount = "56"

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemGroupedBackground
        navigationItem.title = "Profile"
        setupTableView()
    }

    private func setupTableView() {
        view.addSubview(tableView)

        tableView.snp.makeConstraints { make in
            make.edges.equalTo(view.safeAreaLayoutGuide)
        }

        tableView.backgroundColor = .systemGroupedBackground
        tableView.separatorStyle = .none
        tableView.showsVerticalScrollIndicator = false

        // ⭐️ Burada auto height açırıq
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 140

        tableView.register(ProfileHeaderCell.self,
                           forCellReuseIdentifier: ProfileHeaderCell.reuseID)
        tableView.register(ProfileStatsCell.self,
                           forCellReuseIdentifier: ProfileStatsCell.reuseID)
        tableView.register(ProfileMenuCell.self,
                           forCellReuseIdentifier: ProfileMenuCell.reuseID)

        tableView.dataSource = self
        tableView.delegate   = self
    }

    // MARK: - Navigation helpers (eyni qalsın)

    private func openEditProfile() {
        navigationController?.pushViewController(EditProfileViewController(viewModel: EditProfileVM()), animated: true)
    }

    private func openPremium() {
        navigationController?.pushViewController(PremiumViewController(viewModel: PremiumVM()), animated: true)
    }

    private func openMyMemes() {
        navigationController?.pushViewController(MyMemesViewController(), animated: true)
    }

    private func openSavedMemes() {
        navigationController?.pushViewController(SavedMemesViewController(), animated: true)
    }

    private func openSettings() {
        navigationController?.pushViewController(SettingsViewController(viewModel: SettingsVM()), animated: true)
    }

    private func openHelp() {
        navigationController?.pushViewController(HelpFeedbackViewController(), animated: true)
    }
    private func logout() {
        LogoutService.shared.logout()
    }
}

// MARK: - UITableViewDataSource

extension ProfileViewController: UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        Section.allCases.count
    }

    func tableView(_ tableView: UITableView,
                   numberOfRowsInSection section: Int) -> Int {

        guard let section = Section(rawValue: section) else { return 0 }

        switch section {
        case .header: return 1
        case .stats:  return 1
        case .menu:   return MenuRow.allCases.count
        }
    }

    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        guard let section = Section(rawValue: indexPath.section) else {
            return UITableViewCell()
        }

        switch section {
        case .header:
            let cell = tableView.dequeueReusableCell(
                withIdentifier: ProfileHeaderCell.reuseID,
                for: indexPath
            ) as! ProfileHeaderCell

            cell.configure(name: displayName, email: email)
            cell.onEditProfile = { [weak self] in self?.openEditProfile() }
            cell.onGoPremium   = { [weak self] in self?.openPremium() }
            cell.selectionStyle = .none
            return cell

        case .stats:
            let cell = tableView.dequeueReusableCell(
                withIdentifier: ProfileStatsCell.reuseID,
                for: indexPath
            ) as! ProfileStatsCell

            cell.configure(memes: memesCount, saved: savedCount)
            cell.selectionStyle = .none
            return cell

        case .menu:
            let cell = tableView.dequeueReusableCell(
                withIdentifier: ProfileMenuCell.reuseID,
                for: indexPath
            ) as! ProfileMenuCell

            guard let row = MenuRow(rawValue: indexPath.row) else { return cell }

            switch row {
            case .myMemes:
                cell.configure(iconName: "square.grid.2x2.fill",
                               title: "My Memes")
            case .savedMemes:
                cell.configure(iconName: "bookmark.fill",
                               title: "Saved Memes")
            case .settings:
                cell.configure(iconName: "gearshape.fill",
                               title: "Settings")
            case .help:
                cell.configure(iconName: "questionmark.circle.fill",
                               title: "Help & Feedback")
            case .logout:
                cell.configure(iconName: "figure.run",
                               title: "Logout")
            }

            return cell
        }
    }
}

// MARK: - UITableViewDelegate

extension ProfileViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView,
                   didSelectRowAt indexPath: IndexPath) {

        tableView.deselectRow(at: indexPath, animated: true)

        guard let section = Section(rawValue: indexPath.section),
              section == .menu,
              let row = MenuRow(rawValue: indexPath.row) else { return }

        switch row {
        case .myMemes:    openMyMemes()
        case .savedMemes: openSavedMemes()
        case .settings:   openSettings()
        case .help:       openHelp()
        case .logout:     logout()
        }
    }

    // Section header-lar üçün kiçik boşluq
    func tableView(_ tableView: UITableView,
                   heightForHeaderInSection section: Int) -> CGFloat {
        return section == 0 ? 12 : 8
    }

    func tableView(_ tableView: UITableView,
                   viewForHeaderInSection section: Int) -> UIView? {
        UIView()
    }

    func tableView(_ tableView: UITableView,
                   heightForFooterInSection section: Int) -> CGFloat {
        0.01
    }
}

