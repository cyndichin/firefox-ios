// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

import Foundation
import Common
import ComponentLibrary

class PrivateMessageCardCell: UICollectionViewCell, ReusableCell, ThemeApplicable {
    typealias a11y = AccessibilityIdentifiers.PrivateMode.Homepage

    struct PrivateMessageCard: Hashable {
        let title: String
        let body: String
        let link: String
    }

    func applyTheme(theme: Theme) {
        cardContainer.applyTheme(theme: theme)
    }

    enum UX {
        static let textSpacing: CGFloat = 8
        static let standardSpacing: CGFloat = 16
        static let labelSize: CGFloat = 15
        static let cardSizeMaxWidth: CGFloat = 560
    }

    private lazy var cardContainer: ShadowCardView = .build()

    private lazy var mainView: UIView = .build()
    private lazy var contentStackView: UIStackView = .build { stackView in
        stackView.axis = .vertical
        stackView.alignment = .fill
        stackView.distribution = .equalSpacing
        stackView.spacing = UX.textSpacing
    }

    private lazy var headerLabel: UILabel = .build { label in
        label.font = DefaultDynamicFontHelper.preferredFont(
            withTextStyle: .headline,
            size: UX.labelSize
        )
        label.numberOfLines = 0
        label.adjustsFontForContentSizeCategory = true
        label.accessibilityIdentifier = a11y.title
    }

    private lazy var bodyLabel: UILabel = .build { label in
        label.font = DefaultDynamicFontHelper.preferredFont(
            withTextStyle: .body,
            size: UX.labelSize
        )
        label.numberOfLines = 0
        label.adjustsFontForContentSizeCategory = true
        label.accessibilityIdentifier = a11y.body
    }

    private lazy var linkLabel: UILabel = .build { label in
        label.font = DefaultDynamicFontHelper.preferredFont(
            withTextStyle: .body,
            size: UX.labelSize
        )
        label.numberOfLines = 0
        label.adjustsFontForContentSizeCategory = true
        label.accessibilityIdentifier = a11y.link
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLayout()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(with item: PrivateMessageCard, and theme: Theme) {
        headerLabel.text = item.title
        bodyLabel.text = item.body
        linkLabel.text = item.link

        let cardModel = ShadowCardViewModel(view: mainView, a11yId: "PrivateMode.Message.Card")
        cardContainer.configure(cardModel)
        applyTheme(theme: theme)
    }

    private func setupLayout() {
        contentStackView.addArrangedSubview(headerLabel)
        contentStackView.addArrangedSubview(bodyLabel)
        contentStackView.addArrangedSubview(linkLabel)
        mainView.addSubview(contentStackView)
        contentView.addSubview(mainView)

        NSLayoutConstraint.activate([
            mainView.leadingAnchor.constraint(greaterThanOrEqualTo: leadingAnchor),
            mainView.topAnchor.constraint(equalTo: topAnchor),
            mainView.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor),
            mainView.bottomAnchor.constraint(equalTo: bottomAnchor),
            mainView.centerXAnchor.constraint(equalTo: centerXAnchor),
//            mainView.widthAnchor.constraint(equalToConstant: UX.cardSizeMaxWidth).priority(.defaultHigh),
        ])
    }
}
