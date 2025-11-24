//
//  StoryViewerController.swift
//  MemeGenerator
//
//  Created by Emil Maharramov on 19.11.25.
//

import UIKit

// MARK: - Models

struct Story {
    let imageUrl: String
    let duration: TimeInterval
}

struct StoryGroup {
    let username: String
    let avatarUrl: String?
    let stories: [Story]
}

// MARK: - Story Viewer

final class StoryViewerController: UIViewController {
    
    // MARK: - Public
    
    private let group: StoryGroup
    private var currentIndex: Int
    
    // MARK: - UI
    
    private let imageView = UIImageView()
    
    private let progressStack = UIStackView()
    private var progressBars: [UIProgressView] = []
    
    private let headerContainer = UIView()
    private let usernameLabel = UILabel()
    private let closeButton = UIButton(type: .system)
    
    // MARK: - Timer
    
    private var timer: Timer?
    private var currentProgress: Float = 0
    
    // MARK: - Init
    
    init(group: StoryGroup, startIndex: Int = 0) {
        self.group = group
        self.currentIndex = startIndex
        super.init(nibName: nil, bundle: nil)
        modalPresentationStyle = .fullScreen
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        timer?.invalidate()
    }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .black
        
        setupViews()
        setupConstraints()
        configureHeader()
        configureProgressBars()
        setupGestures()
        
        showStory(at: currentIndex)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        timer?.invalidate()
    }
}

// MARK: - Setup UI

private extension StoryViewerController {
    
    func setupViews() {
        // Image
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        view.addSubview(imageView)
        
        // Progress
        progressStack.axis = .horizontal
        progressStack.spacing = 6
        progressStack.distribution = .fillEqually
        view.addSubview(progressStack)
        
        // Header
        view.addSubview(headerContainer)
        headerContainer.addSubview(usernameLabel)
        headerContainer.addSubview(closeButton)
    }
    
    func setupConstraints() {
        imageView.translatesAutoresizingMaskIntoConstraints = false
        progressStack.translatesAutoresizingMaskIntoConstraints = false
        headerContainer.translatesAutoresizingMaskIntoConstraints = false
        usernameLabel.translatesAutoresizingMaskIntoConstraints = false
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            // Progress – safe area altında
            progressStack.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8),
            progressStack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 8),
            progressStack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -8),
            progressStack.heightAnchor.constraint(equalToConstant: 3),
            
            // Header progress-in altında
            headerContainer.topAnchor.constraint(equalTo: progressStack.bottomAnchor, constant: 8),
            headerContainer.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            headerContainer.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            headerContainer.heightAnchor.constraint(equalToConstant: 40),
            
            usernameLabel.leadingAnchor.constraint(equalTo: headerContainer.leadingAnchor, constant: 16),
            usernameLabel.centerYAnchor.constraint(equalTo: headerContainer.centerYAnchor),
            
            closeButton.trailingAnchor.constraint(equalTo: headerContainer.trailingAnchor, constant: -16),
            closeButton.centerYAnchor.constraint(equalTo: headerContainer.centerYAnchor),
            closeButton.widthAnchor.constraint(equalToConstant: 32),
            closeButton.heightAnchor.constraint(equalToConstant: 32),
            
            // Image – qalan bütün sahə
            imageView.topAnchor.constraint(equalTo: headerContainer.bottomAnchor, constant: 8),
            imageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            imageView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    func configureHeader() {
        usernameLabel.font = .systemFont(ofSize: 14, weight: .semibold)
        usernameLabel.textColor = .white
        usernameLabel.text = group.username     // hazırda userId, sonra username ilə əvəz edərsən
        
        closeButton.setImage(UIImage(systemName: "xmark"), for: .normal)
        closeButton.tintColor = .white
        closeButton.addTarget(self, action: #selector(onClose), for: .touchUpInside)
    }
    
    func configureProgressBars() {
        progressBars.removeAll()
        progressStack.arrangedSubviews.forEach { v in
            progressStack.removeArrangedSubview(v)
            v.removeFromSuperview()
        }
        
        for _ in group.stories {
            let bar = UIProgressView(progressViewStyle: .default)
            bar.trackTintColor = UIColor.white.withAlphaComponent(0.3)
            bar.progressTintColor = .white
            bar.progress = 0
            bar.layer.cornerRadius = 1.5
            bar.clipsToBounds = true
            
            progressStack.addArrangedSubview(bar)
            progressBars.append(bar)
        }
    }
    
    func setupGestures() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(onTap(_:)))
        view.addGestureRecognizer(tap)
        
        let swipeDown = UISwipeGestureRecognizer(target: self, action: #selector(onSwipeDown(_:)))
        swipeDown.direction = .down
        view.addGestureRecognizer(swipeDown)
    }
}

// MARK: - Story Logic

private extension StoryViewerController {
    
    func showStory(at index: Int) {
        guard !group.stories.isEmpty else {
            dismiss(animated: true)
            return
        }
        
        guard index >= 0,
              index < group.stories.count,
              index < progressBars.count else {
            dismiss(animated: true)
            return
        }
        
        timer?.invalidate()
        currentProgress = 0
        
        // Keçilmiş storilər 100%, cari 0, gələcək 0
        for (i, bar) in progressBars.enumerated() {
            if i < index {
                bar.progress = 1
            } else {
                bar.progress = 0
            }
        }
        
        let story = group.stories[index]
        imageView.loadImage(story.imageUrl)   // Sənin Kingfisher extension-un
        
        startTimer(for: index, duration: story.duration)
    }
    
    func startTimer(for index: Int, duration: TimeInterval) {
        guard index >= 0,
              index < group.stories.count,
              index < progressBars.count else {
            dismiss(animated: true)
            return
        }
        
        timer?.invalidate()
        currentProgress = 0
        
        let interval: TimeInterval = 0.02
        let safeDuration = max(duration, 0.3)
        let step = Float(interval / safeDuration)
        
        timer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { [weak self] t in
            guard let self = self else {
                t.invalidate()
                return
            }
            
            guard index < self.progressBars.count else {
                t.invalidate()
                self.dismiss(animated: true)
                return
            }
            
            self.currentProgress += step
            self.progressBars[index].progress = min(self.currentProgress, 1.0)
            
            if self.currentProgress >= 1 {
                t.invalidate()
                self.goToNextStory()
            }
        }
    }
    
    func goToNextStory() {
        if currentIndex < group.stories.count - 1 {
            currentIndex += 1
            showStory(at: currentIndex)
        } else {
            dismiss(animated: true)
        }
    }
    
    func goToPreviousStory() {
        if currentIndex > 0 {
            currentIndex -= 1
            showStory(at: currentIndex)
        } else {
            // Birincidə tapsa, sadəcə yenidən həmin storini oynada bilərik
            showStory(at: currentIndex)
        }
    }
}

// MARK: - Actions

private extension StoryViewerController {
    
    @objc func onClose() {
        timer?.invalidate()
        dismiss(animated: true)
    }
    
    @objc func onSwipeDown(_ gesture: UISwipeGestureRecognizer) {
        if gesture.state == .ended {
            onClose()
        }
    }
    
    @objc func onTap(_ gesture: UITapGestureRecognizer) {
        let location = gesture.location(in: view)
        let isRightSide = location.x > view.bounds.width / 2
        
        timer?.invalidate()
        
        if isRightSide {
            goToNextStory()
        } else {
            goToPreviousStory()
        }
    }
}
