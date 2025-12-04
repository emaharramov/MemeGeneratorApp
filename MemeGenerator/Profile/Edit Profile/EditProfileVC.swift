//
//  EditProfileVC.swift
//  MemeGenerator
//
//  Created by Emil Maharramov on 28.11.25.
//

import UIKit
import SnapKit
import Combine

final class EditProfileViewController: BaseController<ProfileVM> {

    private enum Section: Int, CaseIterable {
        case avatar
        case fields
    }

    private enum FieldRow: Int, CaseIterable {
        case fullName
        case username
        case email
    }

    // MARK: - UI

    private let tableView = UITableView(frame: .zero, style: .plain)

    private weak var fullNameField: UITextField?
    private weak var usernameField: UITextField?
    private weak var emailField: UITextField?

    private var cancellables = Set<AnyCancellable>()

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Edit Profile"
        view.backgroundColor = .mgBackground

        setupTableView()
        setupFooter()
        bindViewModel()

        if viewModel.userProfile == nil {
            viewModel.getUserProfile()
        }
    }

    // MARK: - Bindings

    override func bindViewModel() {
        viewModel.$userProfile
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.tableView.reloadData()
            }
            .store(in: &cancellables)

        viewModel.$successMessage
            .compactMap { $0 }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] message in
                guard let self else { return }
//                 self.showToast(message: message, type: .success)

                self.navigationController?.popViewController(animated: true)
            }
            .store(in: &cancellables)
    }


    // MARK: - Setup

    private func setupTableView() {
        view.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.edges.equalTo(view.safeAreaLayoutGuide)
        }

        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none
        tableView.showsVerticalScrollIndicator = false
        tableView.contentInset = UIEdgeInsets(top: 8, left: 0, bottom: 16, right: 0)
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 120

        tableView.register(EditProfileAvatarCell.self,
                           forCellReuseIdentifier: EditProfileAvatarCell.reuseID)
        tableView.register(EditProfileTextFieldCell.self,
                           forCellReuseIdentifier: EditProfileTextFieldCell.reuseID)

        tableView.dataSource = self
        tableView.delegate   = self
    }

    private func setupFooter() {
        let footer = UIView(frame: CGRect(x: 0, y: 0, width: view.bounds.width, height: 96))
        footer.backgroundColor = .clear

        let button = UIButton(type: .system)
        button.applyFilledStyle(
            title: "Save Changes",
            baseBackgroundColor: .mgAccent,
            baseForegroundColor: .black,
            contentInsets: .init(top: 14, leading: 16, bottom: 14, trailing: 16),
            addShadow: true
        )
        button.layer.cornerRadius = 22
        button.clipsToBounds = false
        button.addTarget(self, action: #selector(saveTapped), for: .touchUpInside)

        footer.addSubview(button)
        button.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(12)
            make.leading.trailing.equalToSuperview().inset(16)
            make.bottom.equalToSuperview().inset(12)
        }

        tableView.tableFooterView = footer
    }

    // MARK: - Helpers

    private var currentFullName: String {
        viewModel.userProfile?.data.fullName ?? ""
    }

    private var currentUsername: String {
        viewModel.userProfile?.data.username ?? ""
    }

    private var currentEmail: String {
        viewModel.userProfile?.data.email ?? ""
    }

    // MARK: - Actions

    @objc private func saveTapped() {
        let fullName = fullNameField?.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let username = usernameField?.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let email = emailField?.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""

        guard !username.isEmpty, !email.isEmpty else {
            showToast(message: "Username and email are required", type: .error)
            return
        }

        viewModel.updateProfile(
            fullName: fullName,
            username: username,
            email: email
        )
    }
}

// MARK: - UITableViewDataSource

extension EditProfileViewController: UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        Section.allCases.count
    }

    func tableView(_ tableView: UITableView,
                   numberOfRowsInSection section: Int) -> Int {

        guard let section = Section(rawValue: section) else { return 0 }

        switch section {
        case .avatar: return 1
        case .fields: return FieldRow.allCases.count
        }
    }

    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        guard let section = Section(rawValue: indexPath.section) else {
            return UITableViewCell()
        }

        switch section {
        case .avatar:
            let cell = tableView.dequeueReusableCell(
                withIdentifier: EditProfileAvatarCell.reuseID,
                for: indexPath
            ) as! EditProfileAvatarCell

            let nameForInitials = currentFullName.isEmpty ? currentUsername : currentFullName
            cell.configure(initialsFrom: nameForInitials)
            cell.onChangePhoto = { [weak self] in
                // gələcəkdə avatar seçimi üçün
                self?.showToast(message: "Change photo coming soon", type: .info)
            }
            return cell

        case .fields:
            let cell = tableView.dequeueReusableCell(
                withIdentifier: EditProfileTextFieldCell.reuseID,
                for: indexPath
            ) as! EditProfileTextFieldCell

            guard let row = FieldRow(rawValue: indexPath.row) else { return cell }

            switch row {
            case .fullName:
                cell.configure(
                    title: "Full Name",
                    placeholder: "Enter your full name",
                    text: currentFullName,
                    keyboardType: .default,
                    isEditable: true      // dəyişmək olar
                )
                fullNameField = cell.textField

            case .username:
                cell.configure(
                    title: "Username",
                    placeholder: "@username",
                    text: currentUsername,
                    keyboardType: .default,
                    isEditable: false     // read-only
                )
                usernameField = cell.textField

            case .email:
                cell.configure(
                    title: "Email",
                    placeholder: "you@example.com",
                    text: currentEmail,
                    keyboardType: .emailAddress,
                    isEditable: false  
                )
                emailField = cell.textField
            }

            return cell
        }
    }
}

// MARK: - UITableViewDelegate

extension EditProfileViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView,
                   heightForHeaderInSection section: Int) -> CGFloat {
        section == 0 ? 8 : 16
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
