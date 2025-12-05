//
//  ProfileViewController.swift
//  MemeGenerator
//
//  Created by Emil Maharramov on 19.11.25.
//

import UIKit
import SnapKit
import Combine

final class ProfileViewController: BaseController<ProfileVM> {

    private weak var router: ProfileRouting?
    private var cancellables = Set<AnyCancellable>()

    private enum Section: Int, CaseIterable {
        case header
        case stats
        case menu
    }

    private enum MenuRow: Int, CaseIterable {
        case myMemes
        case savedMemes
        case help
        case logout
    }

    private let tableView = UITableView(frame: .zero, style: .plain)
    private let refreshControl = UIRefreshControl()

    private var memesCount: Int = 0
    private var savedCount: Int = 0

    private var displayName: String {
        let user = viewModel.userProfile?.data

        if let fullName = user?.fullName, !fullName.isEmpty {
            return fullName
        }

        return "Meme Master"
    }

    private var email: String {
        viewModel.userProfile?.data.email.lowercased() ?? "user@example.com"
    }

    private var memesCountText: String {
        String(memesCount)
    }

    private var savedCountText: String {
        String(savedCount)
    }

    init(viewModel: ProfileVM, router: ProfileRouting) {
        self.router = router
        super.init(viewModel: viewModel)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .mgBackground
        navigationItem.title = "Profile"

        setupTableView()
        setupRefreshControl()
        bindViewModel()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.getUserProfile()
    }

    override func bindViewModel() {
        viewModel.$userProfile
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                guard let self else { return }
                self.refreshControl.endRefreshing()
                self.tableView.reloadData()
            }
            .store(in: &cancellables)
    }
    private func setupTableView() {
        view.addSubview(tableView)

        tableView.snp.makeConstraints { make in
            make.edges.equalTo(view.safeAreaLayoutGuide)
        }

        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none
        tableView.showsVerticalScrollIndicator = false
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 160
        tableView.contentInset = UIEdgeInsets(top: 8, left: 0, bottom: 24, right: 0)

        tableView.register(ProfileHeaderCell.self,
                           forCellReuseIdentifier: ProfileHeaderCell.reuseID)
        tableView.register(ProfileStatsCell.self,
                           forCellReuseIdentifier: ProfileStatsCell.reuseID)
        tableView.register(ProfileMenuCell.self,
                           forCellReuseIdentifier: ProfileMenuCell.reuseID)

        tableView.dataSource = self
        tableView.delegate   = self
    }

    private func setupRefreshControl() {
        refreshControl.tintColor = .white
        refreshControl.addTarget(self, action: #selector(handleRefresh), for: .valueChanged)
        tableView.refreshControl = refreshControl
    }

    @objc private func handleRefresh() {
        viewModel.getUserProfile()
    }

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

    private func openHelp() {
        router?.showHelp()
    }

    private func logout() {
        router?.performLogout()
    }

    private func reloadStatsSection() {
        let indexSet = IndexSet(integer: Section.stats.rawValue)
        tableView.reloadSections(indexSet, with: .automatic)
    }
}

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

            let isPremium = viewModel.userProfile?.data.isPremium ?? false

            cell.configure(
                name: displayName,
                email: email,
                isPremium: isPremium
            )

            cell.onEditProfile = { [weak self] in
                self?.openEditProfile()
            }
            cell.onGoPremium   = { [weak self] in
                self?.openPremium()
            }

            return cell

        case .stats:
            let cell: ProfileStatsCell = tableView.dequeueCell(
                ProfileStatsCell.self,
                for: indexPath
            )

            cell.configure(memes: memesCountText, saved: savedCountText)
            return cell

        case .menu:
            let cell: ProfileMenuCell = tableView.dequeueCell(
                ProfileMenuCell.self,
                for: indexPath
            )

            guard let row = MenuRow(rawValue: indexPath.row) else { return cell }

            switch row {
            case .myMemes:
                cell.configure(
                    iconName: "square.grid.2x2.fill",
                    title: "My Memes"
                )
            case .savedMemes:
                cell.configure(
                    iconName: "bookmark.fill",
                    title: "Saved Memes"
                )
            case .help:
                cell.configure(
                    iconName: "questionmark.circle.fill",
                    title: "Help & Feedback"
                )
            case .logout:
                cell.configure(
                    iconName: "figure.run",
                    title: "Logout",
                    isDestructive: true
                )
            }

            return cell
        }
    }
}

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
        case .help:       openHelp()
        case .logout:     logout()
        }
    }

    func tableView(_ tableView: UITableView,
                   heightForHeaderInSection section: Int) -> CGFloat {
        section == 0 ? 4 : 8
    }

    func tableView(_ tableView: UITableView,
                   viewForHeaderInSection section: Int) -> UIView? {
        let v = UIView()
        v.backgroundColor = .clear
        return v
    }

    func tableView(_ tableView: UITableView,
                   heightForFooterInSection section: Int) -> CGFloat {
        0.01
    }
}

extension ProfileViewController: ProfileCountsDelegate {
    func didUpdateMemesCount(_ count: Int) {
        memesCount = count
        reloadStatsSection()
    }

    func didUpdateSavedCount(_ count: Int) {
        savedCount = count
        reloadStatsSection()
    }
}
