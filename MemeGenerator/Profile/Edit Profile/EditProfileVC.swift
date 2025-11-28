//
//  EditProfileVC.swift
//  MemeGenerator
//
//  Created by Emil Maharramov on 28.11.25.
//

import UIKit
import SnapKit

final class EditProfileViewController: BaseController<EditProfileVM> {
    
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    
    private let avatarView = UIView()
    private let avatarImageView = UIImageView()
    private let changePhotoButton = UIButton(type: .system)
    
    private let fullNameField = UITextField()
    private let usernameField = UITextField()
    private let emailField = UITextField()
    private let saveButton = UIButton(type: .system)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemGroupedBackground
        title = "Edit Profile"
        
        setupLayout()
    }
    
    private func setupLayout() {
        view.addSubview(scrollView)
        scrollView.snp.makeConstraints { $0.edges.equalTo(view.safeAreaLayoutGuide) }
        scrollView.addSubview(contentView)
        contentView.snp.makeConstraints {
            $0.edges.equalToSuperview()
            $0.width.equalToSuperview()
        }
        
        avatarView.backgroundColor = .systemGray5
        avatarView.layer.cornerRadius = 40
        avatarView.clipsToBounds = true
        avatarView.snp.makeConstraints { $0.width.height.equalTo(80) }
        
        avatarImageView.image = UIImage(systemName: "person.fill")
        avatarImageView.tintColor = .systemGray
        avatarImageView.contentMode = .scaleAspectFit
        avatarView.addSubview(avatarImageView)
        avatarImageView.snp.makeConstraints { $0.center.equalToSuperview() }
        
        changePhotoButton.setTitle("Change Photo", for: .normal)
        changePhotoButton.setTitleColor(.systemBlue, for: .normal)
        
        let avatarStack = UIStackView(arrangedSubviews: [avatarView, changePhotoButton])
        avatarStack.axis = .vertical
        avatarStack.alignment = .center
        avatarStack.spacing = 12
        
        configureTextField(fullNameField, placeholder: "Full Name")
        configureTextField(usernameField, placeholder: "Username")
        configureTextField(emailField, placeholder: "Email")
        
        var btnConfig = UIButton.Configuration.filled()
        btnConfig.cornerStyle = .large
        btnConfig.title = "Save Changes"
        btnConfig.baseBackgroundColor = .systemBlue
        btnConfig.baseForegroundColor = .white
        saveButton.configuration = btnConfig
        
        let fieldsStack = UIStackView(arrangedSubviews: [fullNameField, usernameField, emailField, saveButton])
        fieldsStack.axis = .vertical
        fieldsStack.spacing = 12
        
        contentView.addSubview(avatarStack)
        contentView.addSubview(fieldsStack)
        
        avatarStack.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(24)
            make.centerX.equalToSuperview()
        }
        
        fieldsStack.snp.makeConstraints { make in
            make.top.equalTo(avatarStack.snp.bottom).offset(24)
            make.leading.trailing.equalToSuperview().inset(16)
            make.bottom.equalToSuperview().inset(24)
        }
        
        [fullNameField, usernameField, emailField].forEach { field in
            field.snp.makeConstraints { $0.height.equalTo(46) }
        }
        saveButton.snp.makeConstraints { $0.height.equalTo(48) }
    }
    
    private func configureTextField(_ tf: UITextField, placeholder: String) {
        tf.placeholder = placeholder
        tf.borderStyle = .roundedRect
        tf.backgroundColor = .systemBackground
    }
}
