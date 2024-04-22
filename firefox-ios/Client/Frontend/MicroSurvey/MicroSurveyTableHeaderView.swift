// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

import Foundation
import Common

class MicroSurveyTableHeaderView: UITableViewHeaderFooterView, ReusableCell, ThemeApplicable {
    private lazy var questionLabel: UILabel = .build { label in
        label.font = FXFontStyles.Regular.body.scaledFont()
        label.text = "How satisfied are you with printing in Firefox?"
        label.numberOfLines = 0
        label.setContentCompressionResistancePriority(.required, for: .vertical)
    }

    private lazy var iconView: UIImageView = .build { imageView in
        imageView.contentMode = .scaleAspectFit
        imageView.image = UIImage(systemName: "printer")
//        imageView.accessibilityIdentifier = "\(self.viewModel.a11yIDRoot)CheckboxView"
//        imageView.isAccessibilityElement = false
    }

    private lazy var horizontalStackView: UIStackView = .build { stackView in
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.spacing = 20
    }

    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        horizontalStackView.addArrangedSubview(iconView)
        horizontalStackView.addArrangedSubview(questionLabel)
        contentView.addSubview(horizontalStackView)

        NSLayoutConstraint.activate(
            [
                horizontalStackView.topAnchor.constraint(equalTo: contentView.topAnchor),
                horizontalStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor,constant: 16),
                horizontalStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
                horizontalStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16),

                iconView.heightAnchor.constraint(equalToConstant: 24),
                iconView.widthAnchor.constraint(equalToConstant: 24)
            ]
        )
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - ThemeApplicable
    func applyTheme(theme: Theme) {
        let colors = theme.colors
        questionLabel.textColor = colors.textPrimary
        backgroundColor = colors.layer2
        iconView.tintColor = colors.iconPrimary
    }
}
