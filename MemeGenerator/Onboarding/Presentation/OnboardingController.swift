//
//  OnboardingController.swift
//  MemeGenerator
//
//  Created by Emil Maharramov on 18.11.25.
//

import UIKit
import SnapKit

final class OnboardingController: BaseController<OnBoardingViewModel>, UIScrollViewDelegate {

    private let scrollView: UIScrollView = {
        let s = UIScrollView()
        s.isPagingEnabled = true
        s.showsHorizontalScrollIndicator = false
        s.showsVerticalScrollIndicator = false
        s.bounces = false
        s.backgroundColor = .clear
        return s
    }()

    private let pagesStackView: UIStackView = {
        let sv = UIStackView()
        sv.axis = .horizontal
        sv.alignment = .fill
        sv.distribution = .fillEqually
        sv.spacing = 0
        return sv
    }()

    private let pageControl: UIPageControl = {
        let pc = UIPageControl()
        pc.currentPageIndicatorTintColor = Palette.mgAccent
        pc.pageIndicatorTintColor = Palette.mgCardStroke
        pc.backgroundColor = .clear
        return pc
    }()

    private let skipButton = UIButton.makeTextButton(
        title: "Skip",
        titleColor: Palette.mgAccent,
        font: .systemFont(ofSize: 16, weight: .medium),
        alignment: .leading
    )

    private let nextButton: UIButton = {
        let btn = UIButton(type: .system)

        btn.applyFilledStyle(
            title: "Next",
            systemImageName: "arrow.forward",
            baseBackgroundColor: Palette.mgAccent,
            baseForegroundColor: Palette.mgTextPrimary,
            contentInsets: .init(top: 14, leading: 32, bottom: 14, trailing: 32),
            cornerStyle: .large,
            addShadow: true
        )

        if var config = btn.configuration {
            config.imagePlacement = .trailing
            config.imagePadding = 8
            btn.configuration = config
        }

        return btn
    }()

    private let getStartedButton: UIButton = {
        let btn = UIButton(type: .system)

        btn.applyFilledStyle(
            title: "Get Started",
            systemImageName: nil,
            baseBackgroundColor: Palette.mgAccent,
            baseForegroundColor: Palette.mgTextPrimary,
            contentInsets: .init(top: 14, leading: 40, bottom: 14, trailing: 40),
            cornerStyle: .large,
            addShadow: true
        )

        btn.isHidden = true
        return btn
    }()

    private let alreadyLabel: UILabel = {
        let l = UILabel()
        l.text = "Already have an account? Log In"
        l.textColor = Palette.mgTextSecondary
        l.font = .systemFont(ofSize: 14, weight: .regular)
        l.textAlignment = .center
        l.isHidden = true
        return l
    }()

    private var currentPage: Int = 0 {
        didSet { updateControlsForPage() }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = Palette.mgBackground
        setupUI()
    }

    private func setupUI() {
        scrollView.delegate = self
        setupHierarchy()
        setupConstraints()
        setupPages()
        setupActions()
    }
}

private extension OnboardingController {

    func setupHierarchy() {
        view.addSubviews(
            scrollView,
            pageControl,
            skipButton,
            nextButton,
            getStartedButton,
            alreadyLabel
        )

        scrollView.addSubview(pagesStackView)
    }

    func setupConstraints() {
        let guide = view.safeAreaLayoutGuide

        scrollView.snp.makeConstraints { make in
            make.top.equalTo(guide.snp.top).offset(40)
            make.leading.trailing.equalToSuperview()
            make.bottom.equalTo(pageControl.snp.top).offset(-24)
        }

        pagesStackView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.height.equalTo(scrollView.snp.height)
        }

        pageControl.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalTo(getStartedButton.snp.top).offset(-16)
        }

        skipButton.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(24)
            make.bottom.equalTo(guide.snp.bottom).inset(24)
        }

        nextButton.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(24)
            make.bottom.equalTo(guide.snp.bottom).inset(24)
            make.height.equalTo(48)
        }

        getStartedButton.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalTo(guide.snp.bottom).inset(24)
            make.height.equalTo(48)
        }

        alreadyLabel.snp.makeConstraints { make in
            make.top.equalTo(getStartedButton.snp.bottom).offset(12)
            make.centerX.equalToSuperview()
        }
    }

    func setupPages() {
        let pages = viewModel.pages
        pageControl.numberOfPages = pages.count
        pageControl.currentPage = 0

        for page in pages {
            let pageView = OnboardingPageView()
            pageView.configure(with: page)
            pagesStackView.addArrangedSubview(pageView)
            pageView.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        }
    }

    func setupActions() {
        skipButton.addTarget(self, action: #selector(skipTapped), for: .touchUpInside)
        nextButton.addTarget(self, action: #selector(nextTapped), for: .touchUpInside)
        getStartedButton.addTarget(self, action: #selector(getStartedTapped), for: .touchUpInside)
        pageControl.addTarget(self, action: #selector(pageControlChanged), for: .valueChanged)
    }

    @objc func skipTapped() {
        viewModel.finish()
    }

    @objc func nextTapped() {
        let nextIndex = min(currentPage + 1, viewModel.pages.count - 1)
        moveToPage(nextIndex, animated: true)
    }

    @objc func getStartedTapped() {
        viewModel.finish()
    }

    @objc func pageControlChanged() {
        moveToPage(pageControl.currentPage, animated: true)
    }

    func moveToPage(_ index: Int, animated: Bool) {
        let width = scrollView.bounds.width
        let offset = CGPoint(x: CGFloat(index) * width, y: 0)
        scrollView.setContentOffset(offset, animated: animated)
        currentPage = index
        pageControl.currentPage = index
    }

    func updateControlsForPage() {
        let isLast = currentPage == viewModel.pages.count - 1
        skipButton.isHidden = isLast
        nextButton.isHidden = isLast
        getStartedButton.isHidden = !isLast
        alreadyLabel.isHidden = true
    }
}

extension OnboardingController {

    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let page = Int(round(scrollView.contentOffset.x / scrollView.bounds.width))
        currentPage = page
        pageControl.currentPage = page
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        scrollView.contentSize = CGSize(
            width: scrollView.bounds.width * CGFloat(viewModel.pages.count),
            height: scrollView.bounds.height
        )
    }
}
