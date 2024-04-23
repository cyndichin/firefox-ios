// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

import Foundation
import Common

class MicroSurveyHeaderView: UIView, ThemeApplicable {
    struct UX {
        static let closeButtonSize = CGSize(width: 30, height: 30)
        static let logoSize = CGSize(width: 24, height: 24)
        static let stackSpacing: CGFloat = 12
    }

    private lazy var logoImage: UIImageView = .build { imageView in
        imageView.image = UIImage(imageLiteralResourceName: ImageIdentifiers.homeHeaderLogoBall)
        imageView.contentMode = .scaleAspectFit
    }

    private var titleLabel: UILabel = .build { label in
        label.adjustsFontForContentSizeCategory = true
        label.font = FXFontStyles.Bold.callout.scaledFont()
        label.numberOfLines = 0
    }

    private lazy var closeButton: UIButton = .build { button in
        button.setImage(UIImage(named: StandardImageIdentifiers.ExtraLarge.crossCircleFill), for: .normal)
//        button.addTarget(self, action: #selector(self.closeTapped), for: .touchUpInside)
//        button.accessibilityLabel = .Shopping.CloseButtonAccessibilityLabel
//        button.accessibilityIdentifier = AccessibilityIdentifiers.FirefoxHomepage.HomeTabBanner.closeButton
    }

    private lazy var headerView: UIStackView = .build { stack in
        stack.distribution = .fillProportionally
        stack.axis = .horizontal
        stack.alignment = .center
        stack.spacing = UX.stackSpacing
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLayout()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(with title: String) {
        titleLabel.text = title
//        closeButton.addTarget(self, action: #selector(closeButtonAction), for: .touchUpInside)
    }

    func applyTheme(theme: Theme) {
        titleLabel.textColor = theme.colors.textPrimary
        closeButton.tintColor = theme.colors.textSecondary
    }

    private func setupLayout() {
        headerView.addArrangedSubview(logoImage)
        headerView.addArrangedSubview(titleLabel)
        headerView.addArrangedSubview(closeButton)

        addSubview(headerView)

        NSLayoutConstraint.activate([
            headerView.topAnchor.constraint(equalTo: topAnchor),
            headerView.leadingAnchor.constraint(equalTo: leadingAnchor),
            headerView.trailingAnchor.constraint(equalTo: trailingAnchor),
            headerView.bottomAnchor.constraint(equalTo: bottomAnchor),

            logoImage.widthAnchor.constraint(equalToConstant: UX.logoSize.width),
            logoImage.heightAnchor.constraint(equalToConstant: UX.logoSize.height),

            closeButton.widthAnchor.constraint(equalToConstant: UX.closeButtonSize.width),
            closeButton.heightAnchor.constraint(equalToConstant: UX.closeButtonSize.height),
        ])
    }
}
