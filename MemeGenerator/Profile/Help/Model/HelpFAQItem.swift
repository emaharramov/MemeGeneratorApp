//
//  HelpFAQItem.swift
//  MemeGenerator
//
//  Created by Emil Maharramov on 05.12.25.
//

//  HelpFAQItem.swift
//  MemeGenerator

import UIKit

enum HelpFAQItemID {
    case premiumBenefits
    case managePremium
    case aiGeneration
    case memesStorage
}

struct HelpFAQItem {
    let id: HelpFAQItemID
    let iconSystemName: String
    let iconBackgroundColor: UIColor
    let title: String
    let body: String
    let linkTitle: String?
}

extension HelpFAQItem {
    static let all: [HelpFAQItem] = [
        HelpFAQItem(
            id: .premiumBenefits,
            iconSystemName: "flame.fill",
            iconBackgroundColor: .systemOrange,
            title: "What do I get with Premium?",
            body: """
Premium unlocks:

• Exclusive meme templates  
• No watermarks on your memes  
• Unlimited AI meme generations  
• A completely ad-free experience

Perfect if you create memes regularly and want everything to feel fast and pro.
""",
            linkTitle: "View Premium benefits"
        ),
        HelpFAQItem(
            id: .managePremium,
            iconSystemName: "arrow.triangle.2.circlepath.circle.fill",
            iconBackgroundColor: .systemGreen,
            title: "How do I restore or manage my Premium?",
            body: """
Changed phone or reinstalled the app?

• Open MemeGenerator  
• Tap the Premium badge  
• Choose “Restore Purchase”

To manage or cancel your subscription, go to:
Settings → Apple ID → Subscriptions → MemeGenerator Premium.
""",
            linkTitle: nil
        ),
        HelpFAQItem(
            id: .aiGeneration,
            iconSystemName: "sparkles",
            iconBackgroundColor: .systemPurple,
            title: "How does AI meme generation work and why can it fail?",
            body: """
AI uses your text prompt to create an image on our secure servers.

It can sometimes fail when:
• Your internet connection is unstable  
• Too many requests are happening at once  
• Your prompt breaks our content rules

If this happens, wait a few seconds and try again with a clearer prompt.
""",
            linkTitle: nil
        ),
        HelpFAQItem(
            id: .memesStorage,
            iconSystemName: "icloud.and.arrow.down.fill",
            iconBackgroundColor: .systemBlue,
            title: "Where are my memes saved and can I lose them?",
            body: """
Your memes are linked to your MemeGenerator account and stored safely in the cloud.

You keep them when:
• You delete and reinstall the app  
• You switch to a new device and sign in again

Only if you delete your account, your memes will be removed permanently.
""",
            linkTitle: nil
        )
    ]
}
