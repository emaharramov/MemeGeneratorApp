//
//  SettingsVC.swift
//  MemeGenerator
//
//  Created by Emil Maharramov on 28.11.25.
//

import UIKit
import SnapKit

final class SettingsViewController: BaseController<SettingsVM>, UITableViewDataSource, UITableViewDelegate {
    
    private enum Row: Int, CaseIterable {
        case language
    }
    
    private let tableView = UITableView(frame: .zero, style: .insetGrouped)
    private var currentLanguage = "English"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .mgBackground
        title = "Settings"
        
        view.addSubview(tableView)
        tableView.snp.makeConstraints { $0.edges.equalTo(view.safeAreaLayoutGuide) }
        
        tableView.dataSource = self
        tableView.delegate   = self
    }
    
    func tableView(_ tableView: UITableView,
                   numberOfRowsInSection section: Int) -> Int {
        Row.allCases.count
    }
    
    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .value1, reuseIdentifier: nil)
        cell.selectionStyle = .default
        
        guard let row = Row(rawValue: indexPath.row) else { return cell }
        switch row {
        case .language:
            cell.textLabel?.text = "Language"
            cell.detailTextLabel?.text = currentLanguage
            cell.accessoryType = .disclosureIndicator
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView,
                   didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        guard Row(rawValue: indexPath.row) == .language else { return }
        
        let alert = UIAlertController(title: "Language",
                                      message: nil,
                                      preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "English", style: .default, handler: { [weak self] _ in
            self?.currentLanguage = "English"
            tableView.reloadData()
        }))
        alert.addAction(UIAlertAction(title: "Русский", style: .default, handler: { [weak self] _ in
            self?.currentLanguage = "Русский"
            tableView.reloadData()
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        present(alert, animated: true)
    }
}
