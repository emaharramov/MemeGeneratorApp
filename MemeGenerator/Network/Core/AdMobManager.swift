//
//  AdMobManager.swift
//  MemeGenerator
//
//  Created by Emil Maharramov on 28.12.25.
//

import GoogleMobileAds
import UIKit

final class AdMobManager: NSObject {

    static let shared = AdMobManager()

    private var interstitialAd: InterstitialAd?
    private var rewardedAd: RewardedAd?

    private var onAdDismissed: (() -> Void)?
    private var onRewardEarned: (() -> Void)?

    private let interstitialAdUnitID = "ca-app-pub-3940256099942544/4411468910"
    private let rewardedAdUnitID = "ca-app-pub-3940256099942544/1712485313"

    private override init() {
        super.init()
    }

    func initialize() {
        MobileAds.shared.start(completionHandler: nil)
    }

    func loadInterstitialAd() {
        InterstitialAd.load(with: interstitialAdUnitID, request: Request()) { [weak self] ad, error in
            guard let self = self, let ad = ad else { return }
            self.interstitialAd = ad
            self.interstitialAd?.fullScreenContentDelegate = self
        }
    }

    func showInterstitialAd(from viewController: UIViewController, onDismissed: @escaping () -> Void) {
        self.onAdDismissed = { [weak self] in
            onDismissed()
            self?.onAdDismissed = nil
        }

        guard let ad = interstitialAd else {
            onDismissed()
            return
        }

        ad.present(from: viewController)
    }

    func loadRewardedAd() {
        RewardedAd.load(with: rewardedAdUnitID, request: Request()) { [weak self] ad, error in
            guard let self = self, let ad = ad else { return }
            self.rewardedAd = ad
            self.rewardedAd?.fullScreenContentDelegate = self
        }
    }

    func showRewardedAd(from viewController: UIViewController, onRewardEarned: @escaping () -> Void) {
        self.onRewardEarned = { [weak self] in
            onRewardEarned()
            self?.onRewardEarned = nil
        }

        guard let ad = rewardedAd else { return }

        ad.present(from: viewController) { [weak self] in
            self?.onRewardEarned?()
        }
    }
}

extension AdMobManager: FullScreenContentDelegate {

    func adDidDismissFullScreenContent(_ ad: FullScreenPresentingAd) {
        if ad is InterstitialAd {
            onAdDismissed?()
            onAdDismissed = nil

            interstitialAd?.fullScreenContentDelegate = nil
            interstitialAd = nil

            loadInterstitialAd()
        }

        if ad is RewardedAd {
            onRewardEarned = nil

            rewardedAd?.fullScreenContentDelegate = nil
            rewardedAd = nil

            loadRewardedAd()
        }
    }

    func ad(_ ad: FullScreenPresentingAd, didFailToPresentFullScreenContentWithError error: Error) {
        if ad is InterstitialAd {
            onAdDismissed?()
            onAdDismissed = nil

            interstitialAd?.fullScreenContentDelegate = nil
            interstitialAd = nil
        }

        if ad is RewardedAd {
            onRewardEarned = nil

            rewardedAd?.fullScreenContentDelegate = nil
            rewardedAd = nil
        }
    }
}
