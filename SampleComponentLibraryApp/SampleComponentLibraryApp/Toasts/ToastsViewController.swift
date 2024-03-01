// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

import Foundation
import ComponentLibrary
import UIKit
import Common

class ToastsViewController: UIViewController, Themeable {
    var themeManager: ThemeManager
    var themeObserver: NSObjectProtocol?
    var notificationCenter: NotificationProtocol = NotificationCenter.default

    private lazy var simpleToastButton: LinkButton = .build { button in
        button.addTarget(self, action: #selector(self.showSimpleToast), for: .touchUpInside)
    }

    private lazy var simpleToast: SimpleToast = SimpleToast()

    private lazy var toastStackView: UIStackView = .build { stackView in
        stackView.distribution = .fill
        stackView.alignment = .fill
        stackView.axis = .vertical
        stackView.spacing = 16
    }

    init(themeManager: ThemeManager = AppContainer.shared.resolve()) {
        self.themeManager = themeManager
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        listenForThemeChange(view)
        applyTheme()

        setupView()

        let linkButtonViewModel = LinkButtonViewModel(title: "Simple Toast",
                                                      a11yIdentifier: "a11yLink")
        
        simpleToastButton.configure(viewModel: linkButtonViewModel)
        simpleToastButton.applyTheme(theme: themeManager.currentTheme)
    }

    @objc
    private func showSimpleToast() {
        SimpleToast().showAlertWithText(
            "This is a simple toast.",
            bottomContainer: self.view,
            theme: self.themeManager.currentTheme
        )
    }

    private func setupView() {
        view.addSubview(toastStackView)
        toastStackView.addArrangedSubview(simpleToastButton)
        NSLayoutConstraint.activate([
            toastStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            toastStackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            toastStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
        ])
    }

    // MARK: Themeable

    func applyTheme() {
        view.backgroundColor = themeManager.currentTheme.colors.layer1
        toastStackView.backgroundColor = .clear
    }
}
