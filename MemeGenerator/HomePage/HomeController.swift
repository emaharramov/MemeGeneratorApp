//
//  HomeController.swift
//  MemeGenerator
//
//  Created by Emil Maharramov on 18.11.25.
//

import UIKit

class HomeController: BaseController<BaseViewModel> {
    
    private lazy var customSearchField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Search..."
        tf.textColor = UIColor(hexStr: "00000059", colorAlpha: 0.35)
        tf.font = .systemFont(ofSize: 14, weight: .regular)
        tf.backgroundColor = UIColor(hexStr: "FFFFFF")
        tf.layer.cornerRadius = 8
        tf.layer.borderColor = UIColor(hexStr: "E0E1E6").cgColor
        tf.layer.borderWidth = 1.0
        tf.layer.masksToBounds = true
        
        let container = UIView(frame: CGRect(x: 0, y: 0, width: 28, height: 28))
        let imageView = UIImageView(image: UIImage(systemName: "magnifyingglass"))
        imageView.tintColor = UIColor(hexStr: "00000059", colorAlpha: 0.35)
        imageView.frame = CGRect(x: 6, y: 6, width: 16, height: 16)
        container.addSubview(imageView)
        
        tf.leftView = container
        tf.leftViewMode = .always
        tf.clearButtonMode = .whileEditing
        tf.setRightPaddingPoints(10)
        tf.translatesAutoresizingMaskIntoConstraints = false
        tf.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        return tf
    }()
    
    private lazy var collectionview: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 12
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.isPagingEnabled = true
        cv.showsVerticalScrollIndicator = false
        cv.backgroundColor = UIColor(hexStr: "FFFFFF")
        cv.dataSource = self
        cv.delegate = self
        cv.translatesAutoresizingMaskIntoConstraints = false
        cv.register(GetPromptCell.self, forCellWithReuseIdentifier: "\(GetPromptCell.self)")
        
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(handleRefresh(_:)), for: .valueChanged)
        cv.refreshControl = refreshControl
        return cv
    }()
    
    private lazy var loadIndicator: UIActivityIndicatorView = {
        let i = UIActivityIndicatorView()
        i.tintColor = .black
        i.translatesAutoresizingMaskIntoConstraints = false
        return i
    }()
    
//    var viewmodel = HomeViewModel()
//    var filteredData: [Obj] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bindViewModel()
//        viewmodel.getPackets()
    }
    
    @objc func handleRefresh(_ sender: UIRefreshControl) {
//        viewmodel.getPackets()
        sender.endRefreshing()
    }
    
    override func bindViewModel() {
//        viewmodel.stateUpdated = { [weak self] state in
//            DispatchQueue.main.async { [weak self] in
//                guard let self else { return }
//                switch state {
//                case .loading:
//                    loadIndicator.startAnimating()
//                case .loaded:
//                    loadIndicator.stopAnimating()
//                case .success:
//                    filteredData = viewmodel.packages
//                    collectionview.reloadData()
//                case .error(let error):
//                    print(error)
//                case .idle:
//                    break
//                }
//            }
//        }
    }
    
    override func configureUI() {
        navigationItem.title = "Store"
        [customSearchField, collectionview, loadIndicator].forEach { view.addSubview($0) }
    }
    
    override func configureConstraints() {
        NSLayoutConstraint.activate([
            customSearchField.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            customSearchField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 12),
            customSearchField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -12),
            customSearchField.heightAnchor.constraint(equalToConstant: 36),
            
            collectionview.topAnchor.constraint(equalTo: customSearchField.bottomAnchor, constant: 10),
            collectionview.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 12),
            collectionview.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -12),
            collectionview.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            loadIndicator.topAnchor.constraint(equalTo: view.topAnchor),
            loadIndicator.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            loadIndicator.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            loadIndicator.trailingAnchor.constraint(equalTo: view.trailingAnchor),
        ])
    }
    
    @objc private func textFieldDidChange(_ textField: UITextField) {
        let searchText = textField.text ?? ""
        if searchText.isEmpty {
//            filteredData = viewmodel.packages
        } else {
//            filteredData = viewmodel.packages.filter {
//                $0.title.lowercased().contains(searchText.lowercased())
//            }
        }
        collectionview.reloadData()
    }
}

// MARK: - CollectionView Delegates

extension HomeController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "\(GetPromptCell.self)", for: indexPath) as! GetPromptCell
        
        cell.layer.borderWidth = 1.0
        cell.layer.cornerRadius = 12
        cell.layer.borderColor = UIColor(hexStr: "E0E1E6").cgColor
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return .init(width: collectionView.bounds.width, height: 60)
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print("tapped")
    }
}
