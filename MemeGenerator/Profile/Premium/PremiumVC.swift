//
//  PremiumVC.swift
//  MemeGenerator
//
//  Created by Emil Maharramov on 28.11.25.
//

import UIKit
import SnapKit

final class PremiumViewController: BaseController<PremiumVM> {

    // MARK: - Sections / Rows

    private enum Section: Int, CaseIterable {
        case header
        case perks
        case plans
    }

    private enum Plan: Int, CaseIterable {
        case yearly
        case monthly
    }

    // MARK: - UI

    private let tableView = UITableView(frame: .zero, style: .plain)

    // Perk məlumatları (ikon + text)
    private let perks: [(String, String)] = [
        ("infinity",    "Unlimited AI Generations"),
        ("drop.fill",   "No More Watermarks"),
        ("rocket.fill", "Early Access to New Styles")
    ]

    // State
    private var selectedPlan: Plan = .yearly {
        didSet { reloadPlansSection() }
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Go Premium"
        view.backgroundColor = .mgBackground

        setupTableView()
        setupFooter()
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
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 140
        tableView.contentInset = UIEdgeInsets(top: 8, left: 0, bottom: 16, right: 0)

        tableView.dataSource = self
        tableView.delegate   = self

        tableView.register(PremiumHeaderCell.self,
                           forCellReuseIdentifier: PremiumHeaderCell.reuseID)
        tableView.register(PremiumPerkCell.self,
                           forCellReuseIdentifier: PremiumPerkCell.reuseID)
        tableView.register(PremiumPlanCell.self,
                           forCellReuseIdentifier: PremiumPlanCell.reuseID)
    }

    private func setupFooter() {
        let footer = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: 140))
        footer.backgroundColor = .clear

        let upgradeButton = UIButton(type: .system)
        upgradeButton.applyFilledStyle(
            title: "Upgrade Now",
            baseBackgroundColor: .mgAccent,
            baseForegroundColor: .black,
            contentInsets: .init(top: 14, leading: 16, bottom: 14, trailing: 16),
            addShadow: true
        )
        upgradeButton.layer.cornerRadius = 24
        upgradeButton.clipsToBounds = false
        upgradeButton.addTarget(self, action: #selector(upgradeTapped), for: .touchUpInside)

        let restoreButton = UIButton(type: .system)
        restoreButton.setTitle("Restore Purchases", for: .normal)
        restoreButton.setTitleColor(.mgTextSecondary, for: .normal)
        restoreButton.titleLabel?.font = .systemFont(ofSize: 13, weight: .medium)
        restoreButton.addTarget(self, action: #selector(restoreTapped), for: .touchUpInside)

        let stack = UIStackView(arrangedSubviews: [upgradeButton, restoreButton])
        stack.axis = .vertical
        stack.spacing = 12
        stack.alignment = .fill

        footer.addSubview(stack)
        stack.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(12)
            make.leading.trailing.equalToSuperview().inset(20)
            make.bottom.equalToSuperview().inset(12)
        }

        upgradeButton.snp.makeConstraints { make in
            make.height.equalTo(54)
        }

        tableView.tableFooterView = footer
    }

    // MARK: - Helpers

    private func reloadPlansSection() {
        guard let index = Section.allCases.firstIndex(of: .plans) else { return }
        let indexSet = IndexSet(integer: index)
        tableView.reloadSections(indexSet, with: .none)
    }

    // MARK: - Actions

    @objc private func upgradeTapped() {
        print("Upgrade with plan:", selectedPlan)
    }

    @objc private func restoreTapped() {
        print("Restore purchases tapped")
    }
}

extension PremiumViewController: UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        Section.allCases.count
    }

    func tableView(_ tableView: UITableView,
                   numberOfRowsInSection section: Int) -> Int {

        guard let section = Section(rawValue: section) else { return 0 }

        switch section {
        case .header: return 1
        case .perks:  return perks.count
        case .plans:  return Plan.allCases.count
        }
    }

    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        guard let section = Section(rawValue: indexPath.section) else {
            return UITableViewCell()
        }

        switch section {

        case .header:
            let cell: PremiumHeaderCell = tableView.dequeueCell(
                PremiumHeaderCell.self,
                for: indexPath
            )

            cell.configure(
                title: "Go Premium",
                subtitle: "Unlock unlimited AI memes, remove watermarks, and get early access to new templates."
            )
            return cell

        case .perks:
            let cell: PremiumPerkCell = tableView.dequeueCell(
                PremiumPerkCell.self,
                for: indexPath
            )

            let perk = perks[indexPath.row]
            cell.configure(iconName: perk.0, text: perk.1)
            return cell

        case .plans:
            let cell: PremiumPlanCell = tableView.dequeueCell(
                PremiumPlanCell.self,
                for: indexPath
            )

            guard let plan = Plan(rawValue: indexPath.row) else { return cell }

            switch plan {
            case .yearly:
                cell.configure(
                    title: "Yearly",
                    priceText: "$39.99 /year",
                    subText: "$3.33 /month",
                    badgeText: "BEST VALUE",
                    isSelected: selectedPlan == .yearly
                )
            case .monthly:
                cell.configure(
                    title: "Monthly",
                    priceText: "$7.99 /month",
                    subText: "Flexible billing",
                    badgeText: nil,
                    isSelected: selectedPlan == .monthly
                )
            }

            return cell
        }
    }
}

extension PremiumViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView,
                   didSelectRowAt indexPath: IndexPath) {

        tableView.deselectRow(at: indexPath, animated: true)

        guard
            let section = Section(rawValue: indexPath.section),
            section == .plans,
            let plan = Plan(rawValue: indexPath.row)
        else { return }

        selectedPlan = plan
    }

    func tableView(_ tableView: UITableView,
                   heightForHeaderInSection section: Int) -> CGFloat {
        section == 0 ? 4 : 16
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
