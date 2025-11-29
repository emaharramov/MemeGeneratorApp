//
//  PremiumVC.swift
//  MemeGenerator
//
//  Created by Emil Maharramov on 28.11.25.
//

import UIKit
import SnapKit

final class PremiumViewController: BaseController<PremiumVM> {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = "Go Premium"
        
        let scroll = UIScrollView()
        let content = UIView()
        view.addSubview(scroll)
        scroll.snp.makeConstraints { $0.edges.equalTo(view.safeAreaLayoutGuide) }
        scroll.addSubview(content)
        content.snp.makeConstraints {
            $0.edges.equalToSuperview()
            $0.width.equalToSuperview()
        }
        
        let iconView = UIView()
        iconView.backgroundColor = UIColor.systemBlue.withAlphaComponent(0.1)
        iconView.layer.cornerRadius = 52
        
        let iconImage = UIImageView(image: UIImage(systemName: "sparkles"))
        iconImage.tintColor = .systemBlue
        iconImage.contentMode = .scaleAspectFit
        iconView.addSubview(iconImage)
        iconImage.snp.makeConstraints { $0.center.equalToSuperview() }
        
        let titleLabel = UILabel()
        titleLabel.text = "Unlock Your Full Meme Potential"
        titleLabel.font = .systemFont(ofSize: 26, weight: .bold)
        titleLabel.textColor = .label
        titleLabel.numberOfLines = 0
        titleLabel.textAlignment = .center
        
        let subtitle = UILabel()
        subtitle.text = "Go Premium to get unlimited AI generations, remove watermarks, and access exclusive content."
        subtitle.font = .systemFont(ofSize: 15)
        subtitle.textColor = .secondaryLabel
        subtitle.numberOfLines = 0
        subtitle.textAlignment = .center
        
        let perksStack = UIStackView()
        perksStack.axis = .vertical
        perksStack.spacing = 10
        
        let perks = [
            "Unlimited AI meme generations",
            "No watermark on exported memes",
            "Exclusive premium templates",
            "Priority support"
        ]
        
        perks.forEach { text in
            let row = UIStackView()
            row.axis = .horizontal
            row.spacing = 8
            row.alignment = .center
            
            let tick = UIImageView(image: UIImage(systemName: "checkmark.circle.fill"))
            tick.tintColor = .systemBlue
            tick.snp.makeConstraints { $0.width.height.equalTo(20) }
            
            let label = UILabel()
            label.text = text
            label.font = .systemFont(ofSize: 15)
            label.textColor = .label
            label.numberOfLines = 0
            
            row.addArrangedSubview(tick)
            row.addArrangedSubview(label)
            perksStack.addArrangedSubview(row)
        }
        
        let upgradeButton = UIButton.makeFilledAction(
            title: "Upgrade Now",
            baseBackgroundColor: .systemBlue,
            baseForegroundColor: .white,
            contentInsets: .init(top: 14, leading: 16, bottom: 14, trailing: 16)
        )
        
        let restoreButton = UIButton(type: .system)
        restoreButton.setTitle("Restore Purchases", for: .normal)
        
        let mainStack = UIStackView(arrangedSubviews: [
            iconView, titleLabel, subtitle, perksStack, upgradeButton, restoreButton
        ])
        mainStack.axis = .vertical
        mainStack.spacing = 20
        mainStack.alignment = .fill
        
        content.addSubview(mainStack)
        mainStack.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(32)
            make.leading.trailing.equalToSuperview().inset(24)
            make.bottom.equalToSuperview().inset(24)
        }
        
        iconView.snp.makeConstraints { make in
            make.height.equalTo(104)
        }
        
        upgradeButton.snp.makeConstraints { make in
            make.height.equalTo(50)
        }
    }
}
