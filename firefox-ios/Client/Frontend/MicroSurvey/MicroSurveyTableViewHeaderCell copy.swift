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

    var checked = false {
        didSet {
            self.checkboxView.image = checked ? UIImage(named: UX.Images.selected) : UIImage(named: UX.Images.notSelected)
        }
    }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        addSubview(checkboxView)
        addSubview(optionLabel)
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

                checkboxView.topAnchor.constraint(equalTo: self.topAnchor, constant: UX.padding.top),
                checkboxView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: UX.padding.leading),
                checkboxView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: UX.padding.bottom),

                checkboxView.trailingAnchor.constraint(equalTo: self.optionLabel.leadingAnchor, constant: -UX.spacing),
                optionLabel.topAnchor.constraint(equalTo: self.topAnchor, constant: UX.padding.top),
                optionLabel.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: UX.padding.bottom),
                optionLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: UX.padding.trailing),
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
