////
////  TemplatesMemeViewController.swift
////  MemeGenerator
////
////  Created by Emil Maharramov on 19.11.25.
////
//
//import UIKit
//
//final class TemplatesMemeViewController: UIViewController {
//
//    private var templates: [TemplateDTO] = []
//    private let collectionView: UICollectionView = {
//        let layout = UICollectionViewFlowLayout()
//        layout.itemSize = CGSize(width: 110, height: 140)
//        layout.minimumInteritemSpacing = 8
//        layout.minimumLineSpacing = 12
//        return UICollectionView(frame: .zero, collectionViewLayout: layout)
//    }()
//
//    private let userId: String
//
//    init(userId: String) {
//        self.userId = userId
//        super.init(nibName: nil, bundle: nil)
//    }
//
//    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        view.backgroundColor = .clear
//        setupCollection()
//        fetchTemplates()
//    }
//
//    private func setupCollection() {
//        view.addSubview(collectionView)
//        collectionView.translatesAutoresizingMaskIntoConstraints = false
//        NSLayoutConstraint.activate([
//            collectionView.topAnchor.constraint(equalTo: view.topAnchor, constant: 8),
//            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
//            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
//            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
//        ])
//
//        collectionView.dataSource = self
//        collectionView.delegate = self
//        collectionView.register(TemplateCell.self, forCellWithReuseIdentifier: "TemplateCell")
//    }
//
//    private func fetchTemplates() {
//        MemeService.shared.fetchTemplates { [weak self] items, error in
//            guard let self = self else { return }
//            DispatchQueue.main.async {
//                if let items = items {
//                    self.templates = items
//                    self.collectionView.reloadData()
//                }
//            }
//        }
//    }
//}
//
//extension TemplatesMemeViewController: UICollectionViewDataSource, UICollectionViewDelegate {
//    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
//        templates.count
//    }
//
//    func collectionView(_ collectionView: UICollectionView,
//                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
//        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TemplateCell", for: indexPath) as! TemplateCell
//        let template = templates[indexPath.item]
//        cell.configure(with: template)
//        return cell
//    }
//
//    func collectionView(_ collectionView: UICollectionView,
//                        didSelectItemAt indexPath: IndexPath) {
//        let template = templates[indexPath.item]
//        let editor = TemplateEditorViewController(template: template)
//        navigationController?.pushViewController(editor, animated: true)
//    }
//}
