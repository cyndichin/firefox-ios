// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

import Foundation
import Common
import ComponentLibrary

class PrivateMessageCardCell: UICollectionViewCell, ReusableCell, ThemeApplicable {
    struct PrivateMessageCard: Hashable {
        let title: String
        let body: String
        let link: String
    }

    func applyTheme(theme: Theme) {
        cardContainer.applyTheme(theme: theme)
    }

    enum UX {
        static let contentStackViewSpacing: CGFloat = 8
        static let contentStackTopPadding: CGFloat = 16
        static let contentStackBottomPadding: CGFloat = 16
        static let contentStackLeadingPadding: CGFloat = 16
        static let contentStackTrailingPadding: CGFloat = 16
        static let labelSize: CGFloat = 15
    }

    private lazy var cardContainer: ShadowCardView = .build()

    private lazy var mainView: UIView = .build()
    private lazy var contentStackView: UIStackView = .build { stackView in
        stackView.axis = .vertical
        stackView.spacing = UX.contentStackViewSpacing
    }

    private lazy var headerLabel: UILabel = .build { label in
        label.font = DefaultDynamicFontHelper.preferredFont(
            withTextStyle: .headline,
            size: UX.labelSize
        )
        label.numberOfLines = 0
    }

    private lazy var bodyLabel: UILabel = .build { label in
        label.font = DefaultDynamicFontHelper.preferredFont(
            withTextStyle: .body,
            size: UX.labelSize
        )
        label.numberOfLines = 0
    }

    private lazy var linkLabel: UILabel = .build { label in
        label.font = DefaultDynamicFontHelper.preferredFont(
            withTextStyle: .body,
            size: UX.labelSize
        )
        label.numberOfLines = 0
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
        addSubviews(cardContainer, mainView)
        mainView.addSubview(contentStackView)
        contentStackView.addArrangedSubview(headerLabel)
        contentStackView.addArrangedSubview(bodyLabel)
        contentStackView.addArrangedSubview(linkLabel)

        NSLayoutConstraint.activate([
            cardContainer.leadingAnchor.constraint(equalTo: leadingAnchor),
            cardContainer.topAnchor.constraint(equalTo: topAnchor),
            cardContainer.trailingAnchor.constraint(equalTo: trailingAnchor),
            cardContainer.bottomAnchor.constraint(equalTo: bottomAnchor),

            contentStackView.topAnchor.constraint(equalTo: cardContainer.topAnchor,
                                                  constant: UX.contentStackTopPadding),
            contentStackView.bottomAnchor.constraint(equalTo: cardContainer.bottomAnchor,
                                                     constant: -UX.contentStackBottomPadding),
            contentStackView.leadingAnchor.constraint(equalTo: cardContainer.leadingAnchor,
                                                      constant: UX.contentStackLeadingPadding),
            contentStackView.trailingAnchor.constraint(equalTo: cardContainer.trailingAnchor,
                                                       constant: -UX.contentStackTrailingPadding),
        ])
    }
}
