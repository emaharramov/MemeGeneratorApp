//
//  ManageSubscriptionVC.swift
//  MemeGenerator
//
//  Created by Emil Maharramov on 28.11.25.
//

import UIKit
import Combine
import SnapKit

final class ManageSubscriptionVC: BaseController<ManageSubscriptionVM> {

    private let scrollView = UIScrollView()
    private let contentView = UIView()

    private let headerView = ManageSubscriptionHeaderView()

    private let historyTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "History"
        label.textColor = Palette.mgTextPrimary
        label.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        return label
    }()

    private let historyEmptyLabel: UILabel = {
        let label = UILabel()
        label.text = "No subscription activity yet."
        label.textColor = Palette.mgTextSecondary
        label.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        label.numberOfLines = 0
        return label
    }()

    private let historyStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 16
        return stack
    }()

    private var cancellables = Set<AnyCancellable>()

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Manage Subscription"
        view.backgroundColor = Palette.mgBackground
        setupLayout()
        setupActions()
        bindViewModel()
        viewModel.getUserProfile()
    }

    private func setupLayout() {
        scrollView.alwaysBounceVertical = true
        scrollView.showsVerticalScrollIndicator = false

        view.addSubviews(scrollView)
        scrollView.snp.makeConstraints { make in
            make.edges.equalTo(view.safeAreaLayoutGuide)
        }

        scrollView.addSubviews(contentView)
        contentView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.equalToSuperview()
        }

        contentView.addSubviews(headerView,historyTitleLabel,historyEmptyLabel, historyStackView)

        headerView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(16)
            make.leading.trailing.equalToSuperview().inset(24)
        }

        historyTitleLabel.snp.makeConstraints { make in
            make.top.equalTo(headerView.snp.bottom).offset(32)
            make.leading.trailing.equalToSuperview().inset(24)
        }

        historyStackView.snp.makeConstraints { make in
            make.top.equalTo(historyTitleLabel.snp.bottom).offset(12)
            make.leading.trailing.equalToSuperview().inset(24)
            make.bottom.equalToSuperview().inset(24)
        }

        historyEmptyLabel.snp.makeConstraints { make in
            make.top.equalTo(historyTitleLabel.snp.bottom).offset(8)
            make.leading.trailing.equalToSuperview().inset(24)
            make.bottom.equalToSuperview().inset(24)
        }

        historyStackView.isHidden = true
        historyEmptyLabel.isHidden = true
    }

    private func setupActions() {
        headerView.onChangePlan = { [weak self] in
            guard let self else { return }
        }

        headerView.onRestorePurchases = { [weak self] in
            guard let self else { return }
        }

        headerView.onManageInAppStore = { [weak self] in
            guard let self else { return }
        }
    }

    override func bindViewModel() {
        viewModel.$currentPlan
            .receive(on: DispatchQueue.main)
            .sink { [weak self] plan in
                guard let self else { return }
                self.headerView.configure(with: plan)
            }
            .store(in: &cancellables)

        viewModel.$historyItems
            .receive(on: DispatchQueue.main)
            .sink { [weak self] items in
                guard let self else { return }

                self.historyStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }

                if items.isEmpty {
                    self.historyStackView.isHidden = true
                    self.historyEmptyLabel.isHidden = false
                } else {
                    self.historyStackView.isHidden = false
                    self.historyEmptyLabel.isHidden = true

                    items.forEach { item in
                        let row = SubscriptionHistoryRowView(item: item)
                        self.historyStackView.addArrangedSubview(row)
                    }
                }
            }
            .store(in: &cancellables)
    }
}

final class ManageSubscriptionHeaderView: UIView {

    var onChangePlan: (() -> Void)?
    var onRestorePurchases: (() -> Void)?
    var onManageInAppStore: (() -> Void)?

    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.text = "View your current plan and manage your subscription."
        label.numberOfLines = 0
        label.textAlignment = .center
        label.textColor = Palette.mgTextSecondary
        label.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        return label
    }()

    private let planCardView: UIView = {
        let v = UIView()
        v.backgroundColor = Palette.mgCard
        v.layer.cornerRadius = 20
        v.layer.masksToBounds = true
        return v
    }()

    private let planBadgeLabel: UILabel = {
        let label = UILabel()
        label.text = "PREMIUM"
        label.textColor = Palette.mgAccent
        label.font = UIFont.systemFont(ofSize: 12, weight: .semibold)
        return label
    }()

    private let planTitleLabel: UILabel = {
        let label = UILabel()
        label.textColor = Palette.mgTextPrimary
        label.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        label.numberOfLines = 0
        return label
    }()

    private let planSubtitleLabel: UILabel = {
        let label = UILabel()
        label.textColor = Palette.mgTextSecondary
        label.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        label.numberOfLines = 0
        return label
    }()

    private let benefitsTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Your benefits"
        label.textColor = Palette.mgTextPrimary
        label.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        return label
    }()

    private let benefitsStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 12
        return stack
    }()

    private let changePlanButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Change Plan", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        button.setTitleColor(Palette.mgBackground, for: .normal)
        button.backgroundColor = Palette.mgAccent
        button.layer.cornerRadius = 24
        button.contentEdgeInsets = UIEdgeInsets(top: 14, left: 16, bottom: 14, right: 16)
        return button
    }()

    private let restorePurchasesButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Restore Purchases", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        button.setTitleColor(Palette.mgTextPrimary, for: .normal)
        button.backgroundColor = Palette.mgCard
        button.layer.cornerRadius = 24
        button.contentEdgeInsets = UIEdgeInsets(top: 14, left: 16, bottom: 14, right: 16)
        return button
    }()

    private let manageInAppStoreButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Manage in App Store", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
        button.setTitleColor(Palette.mgAccent, for: .normal)
        button.backgroundColor = .clear
        return button
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLayout()
        setupBenefits()
        setupActions()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupLayout()
        setupBenefits()
        setupActions()
    }

    func configure(with plan: CurrentPlanViewData?) {
        planTitleLabel.text = plan?.title
        planSubtitleLabel.text = plan?.subtitle
        planSubtitleLabel.isHidden = plan?.subtitle == nil
    }

    private func setupLayout() {
        addSubviews(descriptionLabel,planCardView, benefitsTitleLabel,benefitsStackView, changePlanButton, restorePurchasesButton, manageInAppStoreButton)

        descriptionLabel.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.leading.trailing.equalToSuperview()
        }

        planCardView.snp.makeConstraints { make in
            make.top.equalTo(descriptionLabel.snp.bottom).offset(24)
            make.leading.trailing.equalToSuperview()
        }

        planCardView.addSubviews(planBadgeLabel,planTitleLabel,planSubtitleLabel)

        planBadgeLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(16)
            make.leading.equalToSuperview().inset(20)
            make.trailing.lessThanOrEqualToSuperview().inset(16)
        }

        planTitleLabel.snp.makeConstraints { make in
            make.top.equalTo(planBadgeLabel.snp.bottom).offset(8)
            make.leading.trailing.equalToSuperview().inset(20)
        }

        planSubtitleLabel.snp.makeConstraints { make in
            make.top.equalTo(planTitleLabel.snp.bottom).offset(4)
            make.leading.trailing.equalToSuperview().inset(20)
            make.bottom.equalToSuperview().inset(16)
        }

        benefitsTitleLabel.snp.makeConstraints { make in
            make.top.equalTo(planCardView.snp.bottom).offset(24)
            make.leading.trailing.equalToSuperview()
        }

        benefitsStackView.snp.makeConstraints { make in
            make.top.equalTo(benefitsTitleLabel.snp.bottom).offset(16)
            make.leading.trailing.equalToSuperview()
        }

        changePlanButton.snp.makeConstraints { make in
            make.top.equalTo(benefitsStackView.snp.bottom).offset(32)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(48)
        }

        restorePurchasesButton.snp.makeConstraints { make in
            make.top.equalTo(changePlanButton.snp.bottom).offset(12)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(48)
        }

        manageInAppStoreButton.snp.makeConstraints { make in
            make.top.equalTo(restorePurchasesButton.snp.bottom).offset(16)
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview()
        }
    }

    private func setupBenefits() {
        let benefits = [
            "Unlimited AI generations",
            "No watermarks",
            "Early access to new styles"
        ]

        benefits.forEach { text in
            let row = makeBenefitRow(text: text)
            benefitsStackView.addArrangedSubview(row)
        }
    }

    private func setupActions() {
        changePlanButton.addTarget(self, action: #selector(changePlanTapped), for: .touchUpInside)
        restorePurchasesButton.addTarget(self, action: #selector(restorePurchasesTapped), for: .touchUpInside)
        manageInAppStoreButton.addTarget(self, action: #selector(manageInAppStoreTapped), for: .touchUpInside)
    }

    private func makeBenefitRow(text: String) -> UIStackView {
        let icon = UIImageView()
        icon.image = UIImage(systemName: "checkmark.circle.fill")
        icon.tintColor = Palette.mgAccent
        icon.setContentHuggingPriority(.required, for: .horizontal)
        icon.setContentCompressionResistancePriority(.required, for: .horizontal)

        let label = UILabel()
        label.text = text
        label.textColor = Palette.mgTextPrimary
        label.font = UIFont.systemFont(ofSize: 15, weight: .regular)
        label.numberOfLines = 0

        let stack = UIStackView(arrangedSubviews: [icon, label])
        stack.axis = .horizontal
        stack.spacing = 12
        stack.alignment = .center
        return stack
    }

    @objc private func changePlanTapped() {
        onChangePlan?()
    }

    @objc private func restorePurchasesTapped() {
        onRestorePurchases?()
    }

    @objc private func manageInAppStoreTapped() {
        onManageInAppStore?()
    }
}

final class SubscriptionHistoryRowView: UIView {

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = Palette.mgTextPrimary
        label.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
        label.numberOfLines = 0
        return label
    }()

    private let dateLabel: UILabel = {
        let label = UILabel()
        label.textColor = Palette.mgTextSecondary
        label.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        label.numberOfLines = 0
        return label
    }()

    private let statusLabel: PaddingLabel = {
        let label = PaddingLabel(insets: UIEdgeInsets(all: 8))
        label.font = UIFont.systemFont(ofSize: 12, weight: .semibold)
        label.textColor = UIColor.systemGreen
        label.backgroundColor = UIColor.systemGreen.withAlphaComponent(0.18)
        label.layer.cornerRadius = 10
        label.layer.masksToBounds = true
        return label
    }()

    init(item: SubscriptionHistoryItemViewData) {
        super.init(frame: .zero)
        setupLayout()
        configure(with: item)
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupLayout()
    }

    private func setupLayout() {
        let textStack = UIStackView(arrangedSubviews: [titleLabel, dateLabel])
        textStack.axis = .vertical
        textStack.spacing = 2

        let hStack = UIStackView(arrangedSubviews: [textStack, statusLabel])
        hStack.axis = .horizontal
        hStack.distribution = .fillProportionally
        hStack.spacing = 16
        hStack.alignment = .center

        addSubviews(hStack)
        hStack.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }

    private func configure(with item: SubscriptionHistoryItemViewData) {
        titleLabel.text = item.title
        dateLabel.text = item.dateText
        statusLabel.text = item.statusText
    }
}

final class PaddingLabel: UILabel {

    private let insets: UIEdgeInsets

    init(insets: UIEdgeInsets) {
        self.insets = insets
        super.init(frame: .zero)
    }

    required init?(coder: NSCoder) {
        self.insets = .zero
        super.init(coder: coder)
    }

    override func drawText(in rect: CGRect) {
        super.drawText(in: rect.inset(by: insets))
    }

    override var intrinsicContentSize: CGSize {
        let size = super.intrinsicContentSize
        return CGSize(width: size.width + insets.left + insets.right,
                      height: size.height + insets.top + insets.bottom)
    }
}
