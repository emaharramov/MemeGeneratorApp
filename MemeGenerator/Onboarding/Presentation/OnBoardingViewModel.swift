//
//  OnBoardingViewModel.swift
//  MemeGenerator
//
//  Created by Emil Maharramov on 18.11.25.
//

final class OnBoardingViewModel: BaseViewModel {

    var onFinish: (() -> Void)?
    
    let pages: [OnboardingModel] = [
        .init(
            imageName: "brain.head.profile",
            title: "Welcome to MemeCraft!",
            subtitle: "Your personal AI meme studio.",
            description: "Unleash your creativity and generate hilarious, unique memes in seconds. Just type an idea, and let our AI do the magic!"
        ),
        .init(
            imageName: "sparkles",
            title: "Endless Ideas.",
            subtitle: "Turn any thought into a meme.",
            description: "From random shower thoughts to inside jokes with friends — transform everything into a share-ready meme."
        ),
        .init(
            imageName: "bolt.horizontal.icloud",
            title: "Ready to Meme?",
            subtitle: "Join the creators.",
            description: "Save your creations, share them with the world and become part of a community of meme lovers."
        )
    ]

    func finish() {
        onFinish?()
    }
}
