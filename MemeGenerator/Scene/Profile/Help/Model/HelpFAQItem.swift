//
//  HelpFAQItem.swift
//  MemeGenerator
//
//  Created by Emil Maharramov on 05.12.25.
//

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
}

extension HelpFAQItem {
    static let all: [HelpFAQItem] = [
        HelpFAQItem(
            id: .premiumBenefits,
            iconSystemName: "flame.fill",
            iconBackgroundColor: Palette.mgAccentSoft,
            title: "What do I get with Premium?",
            body: """
Premium turns MemeGenerator into your full-power meme studio:

• Unlimited AI meme generations (no 10-meme limit)  
• No watermarks – clean exports only  
• Access to all current and future Premium features  
• Priority access when traffic is high

Perfect if you create memes regularly and want everything to feel fast, clean and pro.
"""
        ),
        HelpFAQItem(
            id: .managePremium,
            iconSystemName: "arrow.triangle.2.circlepath.circle.fill",
            iconBackgroundColor: Palette.mgAccentSoft,
            title: "How do I restore or manage my Premium?",
            body: """
Changed phone, reinstalled the app or something looks off?

To restore your Premium:
• Open MemeGenerator  
• Tap the Premium badge or “Go Premium”  
• Choose “Restore Purchase”

To manage or cancel your subscription, go to:
Settings → Apple ID → Subscriptions → MemeGenerator Premium.
"""
        ),
        HelpFAQItem(
            id: .aiGeneration,
            iconSystemName: "sparkles",
            iconBackgroundColor: Palette.mgAccentSoft,
            title: "How does AI meme generation work and why can it fail?",
            body: """
Our AI takes your idea (prompt) and turns it into a meme image on our secure servers.

It can sometimes fail when:
• Your internet connection is unstable  
• Too many requests are happening at the same time  
• Your prompt breaks our safety / content rules

If this happens:
• Wait a few seconds and try again  
• Rephrase your prompt to be clearer and safe

You’re never charged extra when an AI generation fails.
"""
        ),
        HelpFAQItem(
            id: .memesStorage,
            iconSystemName: "icloud.and.arrow.down.fill",
            iconBackgroundColor: Palette.mgAccentSoft,
            title: "Where are my memes saved and can I lose them?",
            body: """
Your memes are linked to your MemeGenerator account and stored safely in the cloud.

You keep them when:
• You delete and reinstall the app  
• You switch to a new device and sign in again

You only lose them if you delete your account – then your memes are removed permanently.

If something looks wrong, try signing out and back in before panicking. 🙂
"""
        )
    ]
}
