//
//  OnboardingController.swift
//  MemeGenerator
//
//  Created by Emil Maharramov on 18.11.25.
//

import UIKit

final class OnboardingController: BaseController<OnBoardingViewModel> {
    
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 0
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.isPagingEnabled = true
        cv.showsHorizontalScrollIndicator = false
        cv.dataSource = self
        cv.delegate = self
        cv.register(OnboardingCell.self, forCellWithReuseIdentifier:  "\(OnboardingCell.self)")
        cv.translatesAutoresizingMaskIntoConstraints = false
        return cv
    }()
    
    private lazy var pageControl: UIPageControl = {
       let pc = UIPageControl()
        pc.numberOfPages = viewModel.onboardingData.count
        pc.currentPage = 0
        pc.layer.cornerRadius = 12
        pc.pageIndicatorTintColor = UIColor(red: 0/255, green: 19/255, blue: 41/255, alpha: 0.3)
        pc.currentPageIndicatorTintColor = UIColor(red: 0/255, green: 19/255, blue: 41/255, alpha: 1)
        pc.backgroundColor = UIColor(red: 244/255, green: 245/255, blue: 248/255, alpha: 1)
        return pc
    }()
    
    private lazy var arrowButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setImage(UIImage(systemName: "arrow.right"), for: .normal)
        btn.isHidden = true
        btn.tintColor = .white
        btn.backgroundColor = .systemBlue
        btn.layer.cornerRadius = 16
        btn.clipsToBounds = true
        btn.addTarget(self, action: #selector(arrowButtonTapped), for: .touchUpInside)
        return btn
    }()
    
    override func configureUI() {
        [collectionView, pageControl, arrowButton].forEach { view.addSubview($0) }
    }
    
    override func configureConstraints() {
        [collectionView, pageControl, arrowButton].forEach { $0.translatesAutoresizingMaskIntoConstraints = false }
        
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -130),
            
            pageControl.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            pageControl.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -90),
            
            arrowButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -30),
            arrowButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            arrowButton.widthAnchor.constraint(equalToConstant: 56),
            arrowButton.heightAnchor.constraint(equalToConstant: 56)
        ])
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let pageIndex = Int(scrollView.contentOffset.x / view.frame.width)
        pageControl.currentPage = pageIndex
        arrowButton.isHidden = (pageIndex != viewModel.onboardingData.count - 1)
    }
    
    @objc private func arrowButtonTapped() {
        viewModel.onFinish?()
    }
}


extension OnboardingController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        viewModel.onboardingData.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "\(OnboardingCell.self)", for: indexPath) as! OnboardingCell
        cell.configure(with: viewModel.onboardingData[indexPath.item])
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        .init(width: collectionView.frame.width, height: collectionView.frame.height)
    }
    
}
