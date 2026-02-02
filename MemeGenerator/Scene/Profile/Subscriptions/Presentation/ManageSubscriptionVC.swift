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

    private let rootStack: UIStackView = {
        let s = UIStackView()
        s.axis = .vertical
        s.spacing = 24
        return s
    }()

    private let descriptionLabel: UILabel = {
        let l = UILabel()
        l.text = "View your current plan and manage your subscription."
        l.numberOfLines = 0
        l.textAlignment = .center
        l.textColor = Palette.mgTextSecondary
        l.font = .systemFont(ofSize: 14, weight: .regular)
        return l
    }()

    private let planCardView: UIView = {
        let v = UIView()
        v.backgroundColor = Palette.mgCard
        v.layer.cornerRadius = 24
        v.layer.masksToBounds = true
        return v
    }()

    private let planBadgeLabel: UILabel = {
        let l = UILabel()
        l.text = "PREMIUM"
        l.textColor = Palette.mgAccent
        l.font = .systemFont(ofSize: 12, weight: .semibold)
        return l
    }()

    private let planTitleLabel: UILabel = {
        let l = UILabel()
        l.textColor = Palette.mgTextPrimary
        l.font = .systemFont(ofSize: 20, weight: .semibold)
        l.numberOfLines = 0
        return l
    }()

    private let planSubtitleLabel: UILabel = {
        let l = UILabel()
        l.textColor = Palette.mgTextSecondary
        l.font = .systemFont(ofSize: 14, weight: .regular)
        l.numberOfLines = 0
        return l
    }()

    private let benefitsTitleLabel: UILabel = {
        let l = UILabel()
        l.text = "Your benefits"
        l.textColor = Palette.mgTextPrimary
        l.font = .systemFont(ofSize: 16, weight: .semibold)
        return l
    }()

    private let benefitsStack: UIStackView = {
        let s = UIStackView()
        s.axis = .vertical
        s.spacing = 12
        return s
    }()

    private let historyTitleLabel: UILabel = {
        let l = UILabel()
        l.text = "History"
        l.textColor = Palette.mgTextPrimary
        l.font = .systemFont(ofSize: 16, weight: .semibold)
        return l
    }()

    private let historyEmptyLabel: UILabel = {
        let l = UILabel()
        l.text = "No subscription activity yet."
        l.textColor = Palette.mgTextSecondary
        l.font = .systemFont(ofSize: 14, weight: .regular)
        l.numberOfLines = 0
        return l
    }()

    private let historyStack: UIStackView = {
        let s = UIStackView()
        s.axis = .vertical
        s.spacing = 16
        return s
    }()

    private var cancellables = Set<AnyCancellable>()

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Manage Subscription"
        view.backgroundColor = Palette.mgBackground

        setupLayout()
        setupBenefits()
        bindViewModel()

        viewModel.getUserProfile()
    }

    private func setupLayout() {
        scrollView.alwaysBounceVertical = true
        scrollView.showsVerticalScrollIndicator = false

        view.addSubview(scrollView)
        scrollView.snp.makeConstraints { make in
            make.edges.equalTo(view.safeAreaLayoutGuide)
        }

        scrollView.addSubview(contentView)
        contentView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.equalToSuperview()
        }

        contentView.addSubview(rootStack)
        rootStack.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(16)
            make.leading.trailing.equalToSuperview().inset(24)
            make.bottom.equalToSuperview().inset(24) // scroll content bottom
        }

        let planInnerStack = UIStackView(arrangedSubviews: [planBadgeLabel, planTitleLabel, planSubtitleLabel])
        planInnerStack.axis = .vertical
        planInnerStack.spacing = 8

        planCardView.addSubview(planInnerStack)
        planInnerStack.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(20)
        }

        rootStack.addArrangedSubview(descriptionLabel)
        rootStack.addArrangedSubview(planCardView)

        rootStack.setCustomSpacing(18, after: planCardView)

        rootStack.addArrangedSubview(benefitsTitleLabel)
        rootStack.addArrangedSubview(benefitsStack)

        rootStack.setCustomSpacing(28, after: benefitsStack)

        rootStack.addArrangedSubview(historyTitleLabel)
        rootStack.addArrangedSubview(historyEmptyLabel)
        rootStack.addArrangedSubview(historyStack)

        historyEmptyLabel.isHidden = true
        historyStack.isHidden = true
    }

    private func setupBenefits() {
        let benefits = [
            "Unlimited AI generations",
            "No watermarks",
            "Ad-free experience"
        ]

        benefits.forEach { benefitsStack.addArrangedSubview(makeBenefitRow(text: $0)) }
    }

    override func bindViewModel() {
        viewModel.$currentPlan
            .receive(on: DispatchQueue.main)
            .sink { [weak self] plan in
                guard let self else { return }
                planTitleLabel.text = plan?.title
                planSubtitleLabel.text = plan?.subtitle
                planSubtitleLabel.isHidden = (plan?.subtitle?.isEmpty ?? true)
            }
            .store(in: &cancellables)

        viewModel.$historyItems
            .receive(on: DispatchQueue.main)
            .sink { [weak self] items in
                guard let self else { return }

                self.historyStack.arrangedSubviews.forEach { v in
                    self.historyStack.removeArrangedSubview(v)
                    v.removeFromSuperview()
                }

                let list = items
                if list.isEmpty {
                    self.historyStack.isHidden = true
                    self.historyEmptyLabel.isHidden = false
                } else {
                    self.historyEmptyLabel.isHidden = true
                    self.historyStack.isHidden = false

                    list.forEach { item in
                        self.historyStack.addArrangedSubview(self.makeHistoryRow(item: item))
                        self.historyStack.addArrangedSubview(self.makeDivider())
                    }
                    if let last = self.historyStack.arrangedSubviews.last {
                        self.historyStack.removeArrangedSubview(last)
                        last.removeFromSuperview()
                    }
                }
            }
            .store(in: &cancellables)
    }

    private func makeBenefitRow(text: String) -> UIView {
        let icon = UIImageView(image: UIImage(systemName: "checkmark.circle.fill"))
        icon.tintColor = Palette.mgAccent
        icon.setContentHuggingPriority(.required, for: .horizontal)
        icon.setContentCompressionResistancePriority(.required, for: .horizontal)

        let label = UILabel()
        label.text = text
        label.textColor = Palette.mgTextPrimary
        label.font = .systemFont(ofSize: 15, weight: .regular)
        label.numberOfLines = 0

        let h = UIStackView(arrangedSubviews: [icon, label])
        h.axis = .horizontal
        h.spacing = 12
        h.alignment = .center
        return h
    }

    private func makeHistoryRow(item: SubscriptionHistoryItemViewData) -> UIView {
        let container = UIView()

        let titleLabel = UILabel()
        titleLabel.text = item.title
        titleLabel.textColor = Palette.mgTextPrimary
        titleLabel.font = .systemFont(ofSize: 14, weight: .semibold)
        titleLabel.numberOfLines = 0

        let dateLabel = UILabel()
        dateLabel.text = item.dateText
        dateLabel.textColor = Palette.mgTextSecondary
        dateLabel.font = .systemFont(ofSize: 13, weight: .regular)
        dateLabel.numberOfLines = 0

        let textStack = UIStackView(arrangedSubviews: [titleLabel, dateLabel])
        textStack.axis = .vertical
        textStack.spacing = 2

        let pillView = UIView()
        pillView.backgroundColor = UIColor.systemGreen.withAlphaComponent(0.18)
        pillView.layer.cornerRadius = 10
        pillView.layer.masksToBounds = true

        let statusLabel = UILabel()
        statusLabel.text = item.statusText
        statusLabel.textColor = UIColor.systemGreen
        statusLabel.font = .systemFont(ofSize: 12, weight: .semibold)

        pillView.addSubview(statusLabel)
        statusLabel.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(UIEdgeInsets(top: 6, left: 10, bottom: 6, right: 10))
        }

        let h = UIStackView(arrangedSubviews: [textStack, pillView])
        h.axis = .horizontal
        h.spacing = 16
        h.alignment = .center

        container.addSubview(h)
        h.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        pillView.setContentHuggingPriority(.required, for: .horizontal)
        pillView.setContentCompressionResistancePriority(.required, for: .horizontal)

        return container
    }

    private func makeDivider() -> UIView {
        let v = UIView()
        v.backgroundColor = Palette.mgCardStroke.withAlphaComponent(0.6)
        v.snp.makeConstraints { make in
            make.height.equalTo(1)
        }
        return v
    }
}
