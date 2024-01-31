// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

import Foundation
import UIKit
import Common

struct HomepageHeaderCellViewModel {
    var hidePrivateModeButton: Bool
    var isPrivate: Bool

    private var action: (() -> Void)
    private var homepageTelemetry = HomepageTelemetry()

    init(isPrivate: Bool, hidePrivateModeButton: Bool, action: @escaping () -> Void) {
        self.isPrivate = isPrivate
        self.hidePrivateModeButton = hidePrivateModeButton
        self.action = action
    }

    func switchMode() {
        action()
        homepageTelemetry.sendHomepageTappedTelemetry(enteringPrivateMode: !isPrivate)
    }
}

// Header for the homepage in both normal and private mode
// Contains the firefox logo and the private browsing shortcut button
class HomepageHeaderCell: UICollectionViewCell, ReusableCell {
    enum UX {
        static let iPhoneTopConstant: CGFloat = 16
        static let iPadTopConstant: CGFloat = 54
        static let circleSize = CGRect(width: 40, height: 40)
    }

    var viewModel: HomepageHeaderCellViewModel?
    var actionButtonAction: (() -> Void)?

    private lazy var stackContainer: UIStackView = .build { stackView in
        stackView.axis = .horizontal
        stackView.distribution = .fill
    }

    private lazy var logoHeaderCell: HomeLogoHeaderCell = {
        let logoHeader = HomeLogoHeaderCell()
        return logoHeader
    }()

    private lazy var circularView: UIView = .build { view in
        view.frame = UX.circleSize
        view.backgroundColor = UIColor.white
        view.layer.cornerRadius = view.frame.size.width / 2
        view.isUserInteractionEnabled = true
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.switchMode)))
    }

    private lazy var privateModeButton: UIButton = .build { button in
        let maskImage = UIImage(named: ImageIdentifiers.privateMaskSmall)?.withRenderingMode(.alwaysTemplate)
        button.setImage(maskImage, for: .normal)
        button.addTarget(self, action: #selector(self.switchMode), for: .touchUpInside)
        button.imageView?.contentMode = .scaleAspectFit
        button.accessibilityLabel = .TabTrayToggleAccessibilityLabel
        button.accessibilityHint = .TabTrayToggleAccessibilityHint
    }

    // MARK: - Initializers
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - UI Setup

    func setupView() {
        let isiPad = UIDevice.current.userInterfaceIdiom == .pad
        let topAnchorConstant = isiPad ? UX.iPadTopConstant : UX.iPhoneTopConstant
        privateModeButton.insertSubview(circularView, belowSubview: privateModeButton.imageView ?? privateModeButton)
        stackContainer.addArrangedSubview(logoHeaderCell.contentView)
        stackContainer.addArrangedSubview(privateModeButton)
        contentView.addSubview(stackContainer)

        NSLayoutConstraint.activate([
            stackContainer.topAnchor.constraint(equalTo: contentView.topAnchor, constant: topAnchorConstant),
            stackContainer.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            stackContainer.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            stackContainer.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),

            logoHeaderCell.contentView.centerYAnchor.constraint(equalTo: stackContainer.centerYAnchor),
            privateModeButton.centerYAnchor.constraint(equalTo: stackContainer.centerYAnchor),
            privateModeButton.widthAnchor.constraint(equalToConstant: UX.circleSize.width),

            circularView.topAnchor.constraint(equalTo: privateModeButton.topAnchor),
            circularView.trailingAnchor.constraint(equalTo: privateModeButton.trailingAnchor),
            circularView.leadingAnchor.constraint(equalTo: privateModeButton.leadingAnchor),
            circularView.bottomAnchor.constraint(equalTo: privateModeButton.bottomAnchor),
        ])
    }

    func configure(with viewModel: HomepageHeaderCellViewModel) {
        self.viewModel = viewModel
    }

    @objc
    private func switchMode() {
        viewModel?.switchMode()
    }

    // MARK: - ThemeApplicable
    func applyTheme(theme: Theme) {
        logoHeaderCell.applyTheme(theme: theme)
        guard let viewModel else { return }
        privateModeButton.isHidden = viewModel.hidePrivateModeButton
        let privateModeButtonTintColor = viewModel.isPrivate ? theme.colors.layer2 : theme.colors.iconPrimary
        privateModeButton.imageView?.tintColor = privateModeButtonTintColor
        circularView.backgroundColor = viewModel.isPrivate ? .white : .clear
    }
}
