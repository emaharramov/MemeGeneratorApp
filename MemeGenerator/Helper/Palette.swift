//
//  Palette.swift
//  MemeGenerator
//
//  Created by Emil Maharramov on 06.12.25.
//

import UIKit

enum Palette {
    // MARK: - Backgrounds

    /// Əsas app background
    static let mgBackground = UIColor(
        red: 16/255,
        green: 10/255,
        blue: 25/255,
        alpha: 1
    ) // #100A19

    /// Section / larger block background (header arxası və s.)
    static let mgLightBackground = UIColor(
        red: 22/255,
        green: 15/255,
        blue: 37/255,
        alpha: 1
    ) // #160F25 yaxın ton, bir az açıq

    /// Card surface (profile header, stats, menu cells)
    static let mgCard = UIColor(
        red: 32/255,
        green: 24/255,
        blue: 54/255,
        alpha: 1
    ) // #201836

    /// Daha “elevated” card (məs. stats box-lar, xüsusi bloklar üçün)
    static let mgCardElevated = UIColor(
        red: 42/255,
        green: 32/255,
        blue: 70/255,
        alpha: 1
    ) // #2A2046

    /// Card border / stroke
    static let mgCardStroke = UIColor.white.withAlphaComponent(0.06)

    /// Divider xətti
    static let mgSeparator = UIColor(
        red: 58/255,
        green: 46/255,
        blue: 90/255,
        alpha: 1
    ) // #3A2E5A

    // MARK: - Text

    static let mgTextPrimary   = UIColor.white
    static let mgPromptColor   = UIColor.white.withAlphaComponent(0.90)
    static let mgTextSecondary = UIColor.white.withAlphaComponent(0.65)

    // TextField içində yazı (value)
    static let textFieldTextColor = UIColor.white

    // MARK: - Accent / Buttons

    /// Primary accent (Go Premium, FAB, əsas CTA)
    static let mgAccent = UIColor(
        red: 171/255,
        green: 120/255,
        blue: 52/255,
        alpha: 1
    ) // qızılı

    /// Accent-in soft variantı (background, badge, highlight üçün)
    static let mgAccentSoft = UIColor(
        red: 171/255,
        green: 120/255,
        blue: 52/255,
        alpha: 0.16
    )

    /// Primary filled button background
    static let baseBackgroundColor = mgAccent

    /// Secondary button / pill background (məs: "Edit Profile")
    static let secondaryButtonBackground = mgCardElevated

    /// Tabbar / chip-lər üçün açıq surface
    static let cardBg = mgCard

    // MARK: - Digər

    /// Məsələn textfield background (auth screen-lərdə)
    static let textFieldBackground = UIColor(
        red: 26/255,
        green: 18/255,
        blue: 40/255,
        alpha: 1
    )
}
