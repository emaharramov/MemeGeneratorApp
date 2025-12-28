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
        print("DEBUG::: AdMob initialize() START")

        MobileAds.shared.start { status in
            print("DEBUG::: AdMob SDK initialized")
            print("DEBUG::: Adapter statuses:", status.adapterStatusesByClassName)
        }
    }

    func loadInterstitialAd() {
        print("DEBUG::: loadInterstitialAd CALLED")

        let request = Request()

        InterstitialAd.load(
            with: interstitialAdUnitID,
            request: request
        ) { [weak self] ad, error in
            if let error = error {
                return
            }

            self?.interstitialAd = ad
            self?.interstitialAd?.fullScreenContentDelegate = self
        }
    }

    func showInterstitialAd(
        from viewController: UIViewController,
        onDismissed: @escaping () -> Void
    ) {
        self.onAdDismissed = onDismissed

        guard let ad = interstitialAd else {
            onDismissed()
            return
        }
        ad.present(from: viewController)
    }

    func loadRewardedAd() {
        let request = Request()

        RewardedAd.load(
            with: rewardedAdUnitID,
            request: request
        ) { [weak self] ad, error in
            if let error = error {
                return
            }
            self?.rewardedAd = ad
            self?.rewardedAd?.fullScreenContentDelegate = self
        }
    }

    func showRewardedAd(
        from viewController: UIViewController,
        onRewardEarned: @escaping () -> Void
    ) {
        self.onRewardEarned = onRewardEarned

        if let ad = rewardedAd {
            ad.present(from: viewController) { [weak self] in
                let reward = ad.adReward
                self?.onRewardEarned?()
            }
        }
    }
}

extension AdMobManager: FullScreenContentDelegate {

    func adDidRecordImpression(_ ad: FullScreenPresentingAd) {
        print("📊 Ad impression recorded")
    }

    func adDidDismissFullScreenContent(_ ad: FullScreenPresentingAd) {
        if ad is InterstitialAd {
            onAdDismissed?()
            onAdDismissed = nil
            loadInterstitialAd()
        }
        if ad is RewardedAd {
            onRewardEarned = nil
            loadRewardedAd()
        }
    }

    func ad(_ ad: FullScreenPresentingAd, didFailToPresentFullScreenContentWithError error: Error) {
        if ad is InterstitialAd {
            onAdDismissed?()
            onAdDismissed = nil
        }
    }
}
