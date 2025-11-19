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
    let duration: TimeInterval  // məsələn: 5.0 saniyə
}

struct StoryGroup {
    let username: String
    let avatarUrl: String?
    let stories: [Story]
}

// MARK: - Story Viewer

final class StoryViewerController: UIViewController {
    
    // Public
    private let group: StoryGroup
    private var currentIndex: Int
    
    // UI
    private let imageView = UIImageView()
    private let progressStack = UIStackView()
    private var progressBars: [UIProgressView] = []
    
    private let usernameLabel = UILabel()
    private let closeButton = UIButton(type: .system)
    
    // Timer
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
        
        setupImageView()
        setupHeader()
        setupProgressBars()
        setupGestures()
        
        showStory(at: currentIndex)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        timer?.invalidate()
    }
    
    // MARK: - Setup UI
    
    private func setupImageView() {
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        view.addSubview(imageView)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: view.topAnchor),
            imageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            imageView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    private func setupHeader() {
        // username
        usernameLabel.font = .systemFont(ofSize: 14, weight: .semibold)
        usernameLabel.textColor = .white
        usernameLabel.text = group.username
        
        // close button
        closeButton.setImage(UIImage(systemName: "xmark"), for: .normal)
        closeButton.tintColor = .white
        closeButton.addTarget(self, action: #selector(onClose), for: .touchUpInside)
        
        view.addSubview(usernameLabel)
        view.addSubview(closeButton)
        
        usernameLabel.translatesAutoresizingMaskIntoConstraints = false
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            usernameLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            usernameLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            
            closeButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            closeButton.centerYAnchor.constraint(equalTo: usernameLabel.centerYAnchor)
        ])
    }
    
    private func setupProgressBars() {
        progressStack.axis = .horizontal
        progressStack.spacing = 6
        progressStack.distribution = .fillEqually
        
        view.addSubview(progressStack)
        progressStack.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            progressStack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 8),
            progressStack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -8),
            progressStack.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 4),
            progressStack.heightAnchor.constraint(equalToConstant: 3)
        ])
        
        // username label progress-in altında olsun
        view.bringSubviewToFront(usernameLabel)
        view.bringSubviewToFront(closeButton)
        
        for _ in group.stories {
            let bar = UIProgressView(progressViewStyle: .default)
            bar.progress = 0
            bar.trackTintColor = UIColor.white.withAlphaComponent(0.3)
            bar.progressTintColor = .white
            bar.translatesAutoresizingMaskIntoConstraints = false
            bar.layer.cornerRadius = 1.5
            bar.clipsToBounds = true
            progressBars.append(bar)
            progressStack.addArrangedSubview(bar)
        }
    }
    
    private func setupGestures() {
        // Tap – sol / sağ keçid
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(onTap(_:)))
        view.addGestureRecognizer(tapGesture)
        
        // Swipe down – bağlamaq üçün opsional (Instagram kimi)
        let swipeDown = UISwipeGestureRecognizer(target: self, action: #selector(onSwipeDown(_:)))
        swipeDown.direction = .down
        view.addGestureRecognizer(swipeDown)
    }
    
    // MARK: - Story Logic
    
    private func showStory(at index: Int) {
        guard index >= 0, index < group.stories.count else {
            dismiss(animated: true)
            return
        }
        
        timer?.invalidate()
        currentProgress = 0
        
        // ötənləri 100%, gələcəkləri 0%
        for (i, bar) in progressBars.enumerated() {
            if i < index {
                bar.progress = 1
            } else if i == index {
                bar.progress = 0
            } else {
                bar.progress = 0
            }
        }
        
        let story = group.stories[index]
        loadImage(urlString: story.imageUrl)
        startTimer(for: index, duration: story.duration)
    }
    
    private func loadImage(urlString: String) {
        guard let url = URL(string: urlString) else {
            imageView.image = nil
            return
        }
        URLSession.shared.dataTask(with: url) { [weak self] data, _, _ in
            guard let self, let data = data else { return }
            DispatchQueue.main.async {
                self.imageView.image = UIImage(data: data)
            }
        }.resume()
    }
    
    private func startTimer(for index: Int, duration: TimeInterval) {
        timer?.invalidate()
        currentProgress = 0
        
        let interval: TimeInterval = 0.02
        let step = Float(interval / duration)
        
        timer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { [weak self] t in
            guard let self else { return }
            self.currentProgress += step
            self.progressBars[index].progress = self.currentProgress
            
            if self.currentProgress >= 1 {
                t.invalidate()
                self.currentIndex += 1
                self.showStory(at: self.currentIndex)
            }
        }
    }
    
    // MARK: - Actions
    
    @objc private func onClose() {
        timer?.invalidate()
        dismiss(animated: true)
    }
    
    @objc private func onSwipeDown(_ gesture: UISwipeGestureRecognizer) {
        if gesture.state == .ended {
            onClose()
        }
    }
    
    @objc private func onTap(_ gesture: UITapGestureRecognizer) {
        let location = gesture.location(in: view)
        let isRightSide = location.x > view.bounds.width / 2
        
        if isRightSide {
            // Next story
            if currentIndex < group.stories.count - 1 {
                currentIndex += 1
                showStory(at: currentIndex)
            } else {
                // Son storidirsə – bağla
                dismiss(animated: true)
            }
        } else {
            // Previous story
            if currentIndex > 0 {
                currentIndex -= 1
                showStory(at: currentIndex)
            } else {
                // Birincidirsə – bir şey etmə və ya bağla
                // dismiss(animated: true)
            }
        }
    }
}
