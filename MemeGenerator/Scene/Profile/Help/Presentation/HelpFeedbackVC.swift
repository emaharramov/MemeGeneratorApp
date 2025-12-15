//
//  HelpFeedbackVC.swift
//  MemeGenerator
//
//  Created by Emil Maharramov on 28.11.25.
//

import UIKit
import SnapKit

final class HelpFeedbackVC: BaseController<HelpFeedbackVM> {

    private weak var router: ProfileRouting?
    private let tableView = UITableView(frame: .zero, style: .plain)

    private let footerCard = UIView()
    private let footerTitleLabel = UILabel()
    private let footerButton = UIButton(type: .system)

    init(viewModel: HelpFeedbackVM, router: ProfileRouting) {
        self.router = router
        super.init(viewModel: viewModel)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigation()
        setupTableView()
        setupFooterCard()
    }

    private func setupNavigation() {
        navigationItem.title = "Help & FAQ"
        view.backgroundColor = Palette.mgBackground
    }

    private func setupTableView() {
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none
        tableView.showsVerticalScrollIndicator = false
        tableView.alwaysBounceVertical = true

        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 80

        tableView.dataSource = self
        tableView.delegate = self

        tableView.register(
            HelpFAQCell.self,
            forCellReuseIdentifier: HelpFAQCell.reuseID
        )

        view.addSubviews(tableView)
        tableView.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.bottom.equalToSuperview()
        }

        let bottomInset: CGFloat = 120
        tableView.contentInset = UIEdgeInsets(top: 16, left: 0, bottom: bottomInset, right: 0)
        tableView.verticalScrollIndicatorInsets = UIEdgeInsets(top: 0, left: 0, bottom: bottomInset, right: 0)
    }

    private func setupFooterCard() {
        footerCard.applyFAQCardStyle()

        view.addSubviews(footerCard)
        footerCard.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(16)
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).inset(35)
        }

        let stack = UIStackView()
        stack.axis = .vertical
        stack.alignment = .center
        stack.spacing = 4

        footerTitleLabel.text = "Need more help?"
        footerTitleLabel.applyFAQFooterTitleStyle()
        footerTitleLabel.textAlignment = .center

        footerButton.setTitle("Contact Support", for: .normal)
        footerButton.applyFAQLinkStyle()
        footerButton.addTarget(self, action: #selector(contactSupportTapped), for: .touchUpInside)

        stack.addArrangedSubview(footerTitleLabel)
        stack.addArrangedSubview(footerButton)

        footerCard.addSubviews(stack)
        stack.snp.makeConstraints { make in
            make.edges.equalToSuperview()
                .inset(UIEdgeInsets(top: 10, left: 12, bottom: 10, right: 12))
        }
    }

    @objc private func contactSupportTapped() {
         router?.showSupport()
        print("Contact Support tapped")
    }
}

extension HelpFeedbackVC: UITableViewDataSource {

    func tableView(_ tableView: UITableView,
                   numberOfRowsInSection section: Int) -> Int {
        viewModel.numberOfItems
    }

    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: HelpFAQCell = tableView.dequeueCell(
            HelpFAQCell.self,
            for: indexPath
        )

        let item = viewModel.item(at: indexPath.row)
        let expanded = viewModel.isItemExpanded(indexPath.row)
        cell.configure(with: item, expanded: expanded)
        return cell
    }
}

extension HelpFeedbackVC: UITableViewDelegate {

    func tableView(_ tableView: UITableView,
                   didSelectRowAt indexPath: IndexPath) {

        viewModel.handleTap(at: indexPath.row)

        let indexPaths = (0..<viewModel.numberOfItems).map {
            IndexPath(row: $0, section: 0)
        }

        tableView.beginUpdates()
        tableView.reloadRows(at: indexPaths, with: .automatic)
        tableView.endUpdates()
    }
}
