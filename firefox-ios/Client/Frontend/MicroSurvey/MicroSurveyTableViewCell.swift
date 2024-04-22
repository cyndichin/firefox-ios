// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

import Foundation
import Common

class MicroSurveyTableViewCell: UITableViewCell, ReusableCell, ThemeApplicable {
    private struct UX {
        static let spacing: CGFloat = 12
        static let padding = NSDirectionalEdgeInsets(
            top: 10,
            leading: 16,
            bottom: -10,
            trailing: 0
        )

        struct Images {
            static let selected = ImageIdentifiers.Onboarding.MultipleChoiceButtonImages.checkmarkFilled
            static let notSelected = ImageIdentifiers.Onboarding.MultipleChoiceButtonImages.checkmarkEmpty
        }
    }
    private lazy var optionLabel: UILabel = .build { label in
        label.font = FXFontStyles.Regular.body.scaledFont()
        label.numberOfLines = 2
        label.lineBreakMode = .byWordWrapping
    }

    private lazy var checkboxView: UIImageView = .build { imageView in
        imageView.contentMode = .scaleAspectFit
        imageView.image = UIImage(named: UX.Images.notSelected)
        imageView.accessibilityIdentifier = "AccessibilityIdentifier"
        imageView.isAccessibilityElement = false
    }

    private lazy var horizontalStackView: UIStackView = .build { stackView in
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.spacing = UX.spacing
    }

    var checked = false {
        didSet {
            self.checkboxView.image = checked ? UIImage(named: UX.Images.selected) : UIImage(named: UX.Images.notSelected)
        }
    }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        horizontalStackView.addArrangedSubview(checkboxView)
        horizontalStackView.addArrangedSubview(optionLabel)
        addSubview(horizontalStackView)
        setupLayout()
        self.tintColor = UIColor.label
        self.preservesSuperviewLayoutMargins = false
        self.selectionStyle = .none
    }

    private func setupLayout() {
        NSLayoutConstraint.activate(
            [
                checkboxView.widthAnchor.constraint(equalToConstant: 24),
                checkboxView.heightAnchor.constraint(equalToConstant: 24),

                horizontalStackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: UX.padding.top),
                horizontalStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: UX.padding.leading),
                horizontalStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -UX.padding.trailing),
                horizontalStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -UX.padding.bottom),
            ]
        )
    }

    func configureCell(_ text: String) {
        optionLabel.text = text
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func applyTheme(theme: Theme) {
        let colors = theme.colors
        optionLabel.textColor = colors.textPrimary
        imageView?.image = imageView?.image?.withRenderingMode(.alwaysTemplate)
        imageView?.tintColor = colors.textPrimary
        backgroundColor = colors.layer2
        tintColor = colors.textPrimary
    }
}
