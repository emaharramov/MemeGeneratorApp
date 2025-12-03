//
//  TemplatePickerViewController.swift
//  MemeGenerator
//
//  Created by Emil Maharramov on 01.12.25.
//

import UIKit
import SnapKit

final class TemplatePickerViewController: UIViewController {

    var onTemplateSelected: ((TemplateDTO) -> Void)?

    private let templates: [TemplateDTO]
    private let collectionView: UICollectionView

    private let columns: CGFloat = 3
    private let spacing: CGFloat = 12

    init(templates: [TemplateDTO]) {
        self.templates = templates

        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        self.collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)

        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .mgCard
        title = "Choose a Template"

        collectionView.backgroundColor = .clear
        collectionView.alwaysBounceVertical = true
        collectionView.contentInset = UIEdgeInsets(top: 16, left: 16, bottom: 24, right: 16)

        collectionView.dataSource = self
        collectionView.delegate = self

        collectionView.register(TemplatePickerCell.self,
                                forCellWithReuseIdentifier: TemplatePickerCell.reuseId)

        view.addSubview(collectionView)
        collectionView.snp.makeConstraints { make in
            make.edges.equalTo(view.safeAreaLayoutGuide)
        }
    }
}

extension TemplatePickerViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        templates.count
    }

    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: TemplatePickerCell = collectionView.dequeueCell(
            TemplatePickerCell.self,
            for: indexPath
        )
        let template = templates[indexPath.item]
        cell.configure(with: template)
        return cell
    }
}

extension TemplatePickerViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {

        let availableWidth = collectionView.bounds.width
            - collectionView.contentInset.left
            - collectionView.contentInset.right
        let totalSpacing = (columns - 1) * spacing
        let itemWidth = floor((availableWidth - totalSpacing) / columns)

        return CGSize(width: itemWidth, height: itemWidth * 1.25)
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        spacing
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        spacing
    }

    func collectionView(_ collectionView: UICollectionView,
                        didSelectItemAt indexPath: IndexPath) {
        let template = templates[indexPath.item]
        dismiss(animated: true) { [weak self] in
            self?.onTemplateSelected?(template)
        }
    }
}
