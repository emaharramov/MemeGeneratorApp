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
        case avatar, fields
    }

    private enum FieldRow: Int, CaseIterable {
        case fullName, username, email
    }

    private lazy var tableView: UITableView = {
        let tv = UITableView(frame: .zero, style: .plain)
        tv.backgroundColor = .clear
        tv.separatorStyle = .none
        tv.showsVerticalScrollIndicator = false
        tv.contentInset = UIEdgeInsets(top: 8, left: 0, bottom: 16, right: 0)
        tv.rowHeight = UITableView.automaticDimension
        tv.estimatedRowHeight = 120
        tv.register(EditProfileAvatarCell.self, forCellReuseIdentifier: EditProfileAvatarCell.reuseID)
        tv.register(EditProfileTextFieldCell.self, forCellReuseIdentifier: EditProfileTextFieldCell.reuseID)
        tv.dataSource = self
        tv.delegate = self
        return tv
    }()

    private lazy var saveButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.applyFilledStyle(
            title: "Save Changes",
            baseBackgroundColor: Palette.mgAccent,
            baseForegroundColor: .black,
            contentInsets: .init(top: 14, leading: 16, bottom: 14, trailing: 16),
            addShadow: true
        )
        btn.layer.cornerRadius = 22
        btn.clipsToBounds = false
        btn.addTarget(self, action: #selector(saveTapped), for: .touchUpInside)
        return btn
    }()

    private lazy var deleteButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.applyFilledStyle(
            title: "Delete Account",
            baseBackgroundColor: .systemRed,
            baseForegroundColor: .white,
            contentInsets: .init(top: 14, leading: 16, bottom: 14, trailing: 16),
            addShadow: true
        )
        btn.layer.cornerRadius = 22
        btn.clipsToBounds = false
        btn.addTarget(self, action: #selector(deleteTapped), for: .touchUpInside)
        return btn
    }()

    private weak var fullNameField: UITextField?
    private weak var usernameField: UITextField?
    private weak var emailField: UITextField?

    private var selectedAvatarImage: UIImage?
    private var cancellables = Set<AnyCancellable>()

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Edit Profile"
        view.backgroundColor = Palette.mgBackground

        setupTableView()
        setupFooter()
        bindViewModel()

        if viewModel.userProfile == nil {
            viewModel.getUserProfile()
        }
    }

    override func bindViewModel() {
        viewModel.$userProfile
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                guard let self else { return }
                self.selectedAvatarImage = nil
                self.tableView.reloadData()
            }
            .store(in: &cancellables)

        viewModel.$successMessage
            .compactMap { $0 }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] message in
                guard let self else { return }
                self.showToast(message: message, type: .success)
                self.navigationController?.popViewController(animated: true)
            }
            .store(in: &cancellables)

        viewModel.$isFeatureEnabled
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isEnabled in
                self?.deleteButton.isHidden = isEnabled
            }
            .store(in: &cancellables)
    }

    private func setupTableView() {
        view.addSubview(tableView)
        tableView.snp.makeConstraints { $0.edges.equalTo(view.safeAreaLayoutGuide) }
    }

    private func setupFooter() {
        let footer = UIView()
        footer.backgroundColor = .clear
        footer.frame.size.height = 160

        footer.addSubviews(saveButton, deleteButton)

        saveButton.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(12)
            make.leading.trailing.equalToSuperview().inset(16)
            make.height.equalTo(52)
        }

        deleteButton.snp.makeConstraints { make in
            make.top.equalTo(saveButton.snp.bottom).offset(12)
            make.leading.trailing.equalToSuperview().inset(16)
            make.height.equalTo(52)
        }

        tableView.tableFooterView = footer
    }

    @objc private func saveTapped() {
        let fullName = fullNameField?.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let username = usernameField?.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let email = emailField?.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""

        guard !username.isEmpty, !email.isEmpty else {
            showToast(message: "Username and email are required", type: .error)
            return
        }

        var avatarUrlToSend = viewModel.userProfile?.data.user.avatarUrl ?? ""

        if let image = selectedAvatarImage,
           let data = image.resizedToMaxDimension(256).jpegData(compressionQuality: 0.35) {
            avatarUrlToSend = data.base64EncodedString()
        }

        viewModel.updateProfile(
            avatarUrl: avatarUrlToSend,
            fullName: fullName,
            username: username,
            email: email
        )
    }

    @objc private func deleteTapped() {
        MGAlertOverlay.show(
            on: view,
            title: "Delete Account",
            message: "Are you sure you want to delete your account? This action cannot be undone.",
            primaryTitle: "Delete",
            secondaryTitle: "Cancel",
            emoji: "⚠️",
            onPrimary: { [weak self] in
                guard let self else { return }
                self.viewModel.deleteUserAccount()
                self.showToast(message: "Account deleted", type: .success)
            }
        )
    }

    private func presentAvatarPicker() {
        let picker = UIImagePickerController()
        picker.sourceType = .photoLibrary
        picker.allowsEditing = false
        picker.delegate = self
        present(picker, animated: true)
    }

    private var currentFullName: String { viewModel.userProfile?.data.user.fullName ?? "" }
    private var currentUsername: String { viewModel.userProfile?.data.user.username ?? "" }
    private var currentEmail: String { viewModel.userProfile?.data.user.email ?? "" }
    private var currentAvatarUrl: String { viewModel.userProfile?.data.user.avatarUrl ?? "" }
}

extension EditProfileViewController: UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int { Section.allCases.count }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let section = Section(rawValue: section) else { return 0 }
        return section == .avatar ? 1 : FieldRow.allCases.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        guard let section = Section(rawValue: indexPath.section) else { return UITableViewCell() }

        switch section {
        case .avatar:
            let cell = tableView.dequeueReusableCell(withIdentifier: EditProfileAvatarCell.reuseID, for: indexPath) as! EditProfileAvatarCell
            let nameForInitials = currentFullName.isEmpty ? currentUsername : currentFullName
            cell.configure(
                initialsFrom: nameForInitials,
                avatarBase64: currentAvatarUrl,
                pickedImage: selectedAvatarImage
            )
            cell.onChangePhoto = { [weak self] in self?.presentAvatarPicker() }
            return cell

        case .fields:
            let cell = tableView.dequeueReusableCell(withIdentifier: EditProfileTextFieldCell.reuseID, for: indexPath) as! EditProfileTextFieldCell
            guard let row = FieldRow(rawValue: indexPath.row) else { return cell }

            switch row {
            case .fullName:
                cell.configure(
                    title: "Full Name",
                    placeholder: "Enter your full name",
                    text: currentFullName,
                    keyboardType: .default,
                    isEditable: true
                )
                fullNameField = cell.textField

            case .username:
                cell.configure(
                    title: "Username",
                    placeholder: "@username",
                    text: currentUsername,
                    keyboardType: .default,
                    isEditable: false
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

extension EditProfileViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        section == 0 ? 8 : 16
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let v = UIView()
        v.backgroundColor = .clear
        return v
    }

    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        0.01
    }
}

extension EditProfileViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true) { [weak self] in
            guard let self else { return }
            guard let image = (info[.editedImage] as? UIImage) ?? (info[.originalImage] as? UIImage) else { return }

            let cropVC = AvatarCropViewController(image: image)
            cropVC.onCrop = { [weak self] croppedImage in
                self?.selectedAvatarImage = croppedImage
                self?.tableView.reloadSections(IndexSet(integer: Section.avatar.rawValue), with: .automatic)
            }
            self.present(cropVC, animated: true)
        }
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
    }
}
