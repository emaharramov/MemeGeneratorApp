//
//  OnBoardingViewModel.swift
//  MemeGenerator
//
//  Created by Emil Maharramov on 18.11.25.
//

import Foundation

class OnBoardingViewModel:BaseViewModel {
    var onFinish: (() -> Void)?
    
    var onboardingData: [OnboardingModel] = [
                                            .init(imageName: "slideone", title: "Save links, simplify life", description: "Keep track of your favorite articles, videos, and more in one place - never lose a link again"),
                                             .init(imageName: "slidetwo", title: "Save links, simplify life", description: "Keep track of your favorite articles, videos, and more in one place - never lose a link again"),
                                            .init(imageName: "slidethree", title: "Save links, simplify life", description: "Quickly search your collection and access your saved links anytime and anywhere")]
}
