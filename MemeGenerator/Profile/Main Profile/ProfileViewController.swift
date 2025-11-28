//
//  ProfileViewController.swift
//  MemeGenerator
//
//  Created by Emil Maharramov on 19.11.25.
//

import UIKit
import SnapKit

final class ProfileViewController: UIViewController {

    private weak var router: ProfileRouting?
    
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

    // MARK: - UI

    private let tableView = UITableView(frame: .zero, style: .plain)

    // Demo data
    private let displayName = "Meme Master"
    private let email = "user@example.com"
    private let memesCount = "142"
    private let savedCount = "56"

    // MARK: - Init

    init(router: ProfileRouting) {
        self.router = router
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

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

    // MARK: - Router helper-lər (push YOX, sadəcə router çağırır)

    private func openEditProfile() {
        router?.showEditProfile()
    }

    private func openPremium() {
        router?.showPremium()
    }

    private func openMyMemes() {
        router?.showMyMemes()
    }

    private func openSavedMemes() {
        router?.showSavedMemes()
    }

    private func openSettings() {
        router?.showSettings()
    }

    private func openHelp() {
        router?.showHelp()
    }

    private func logout() {
        router?.performLogout()
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
            let cell: ProfileHeaderCell = tableView.dequeueCell(
                ProfileHeaderCell.self,
                for: indexPath
            )

            cell.configure(name: displayName, email: email)

            cell.onEditProfile = { [weak self] in
                self?.openEditProfile()
            }
            cell.onGoPremium   = { [weak self] in
                self?.openPremium()
            }

            cell.selectionStyle = .none
            return cell

        case .stats:
            let cell: ProfileStatsCell = tableView.dequeueCell(
                ProfileStatsCell.self,
                for: indexPath
            )

            cell.configure(memes: memesCount, saved: savedCount)
            cell.selectionStyle = .none
            return cell

        case .menu:
            let cell: ProfileMenuCell = tableView.dequeueCell(
                ProfileMenuCell.self,
                for: indexPath
            )

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

        // 🔹 Burada da router istifadə edirik
        switch row {
        case .myMemes:    openMyMemes()
        case .savedMemes: openSavedMemes()
        case .settings:   openSettings()
        case .help:       openHelp()
        case .logout:     logout()
        }
    }

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
