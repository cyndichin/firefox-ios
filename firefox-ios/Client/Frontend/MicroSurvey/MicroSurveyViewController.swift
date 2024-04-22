// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

import Foundation
import Common
import ComponentLibrary

class MicroSurveyViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, Themeable {
    // MARK: Theming Variables
    var themeManager: Common.ThemeManager
    var themeObserver: NSObjectProtocol?
    var notificationCenter: Common.NotificationProtocol
    private let windowUUID: WindowUUID
    var currentWindowUUID: UUID? { windowUUID }
    weak var coordinator: MicroSurveyCoordinatorDelegate?

    // MARK: UI Elements
    private lazy var tableView: UITableView = .build { [weak self] tableView in
        guard let self = self else { return }
        tableView.accessibilityIdentifier = "Login Detail List"
        tableView.delegate = self
        tableView.dataSource = self
        tableView.isScrollEnabled = false

        // Add empty footer view to prevent separators from being drawn past the last item.
        tableView.tableFooterView = UIView()
        tableView.layer.cornerRadius = 16.0
        tableView.register(MicroSurveyTableHeaderView.self,
                           forHeaderFooterViewReuseIdentifier: MicroSurveyTableHeaderView.cellIdentifier)
        tableView.setContentCompressionResistancePriority(.required, for: .vertical)
        tableView.estimatedRowHeight = 44
        tableView.estimatedSectionHeaderHeight = 100
        tableView.rowHeight = UITableView.automaticDimension
    }

    var options = ["Very Dissatisfied", "Dissatisfied", "Neutral", "Satisfied", "Very Satisfied"]

    private enum UX {
        static let titleStackSpacing: CGFloat = 8
        static let padding: CGFloat = 16
    }

    private lazy var microSurveyHeaderView: MicroSurveyHeaderView = {
        let header = MicroSurveyHeaderView()
        header.configure(with: "Complete the survey")
        return header
    }()

    private lazy var privacyPolicyButton: LinkButton = .build { button in
        let privacyPolicyButtonViewModel = LinkButtonViewModel(
            title: "Privacy Policy",
            a11yIdentifier: "a11y",
            font: FXFontStyles.Regular.footnote.scaledFont(),
            contentInsets: NSDirectionalEdgeInsets(top: 8, leading: 16, bottom: 16, trailing: 16)
        )
        button.configure(viewModel: privacyPolicyButtonViewModel)
        button.addTarget(self, action: #selector(self.didTapPrivacyPolicy), for: .touchUpInside)
        button.setContentCompressionResistancePriority(.required, for: .vertical)
    }

    private lazy var submitButton: PrimaryRoundedButton = .build { button in
        let viewModel = PrimaryRoundedButtonViewModel(
            title: "Submit",
            a11yIdentifier: "a11y"
        )
        button.configure(viewModel: viewModel)
        button.addTarget(self, action: #selector(self.didTapSubmit), for: .touchUpInside)
    }

    private lazy var closeButton: PrimaryRoundedButton = .build { button in
        let viewModel = PrimaryRoundedButtonViewModel(
            title: "Close",
            a11yIdentifier: "a11y"
        )
        button.configure(viewModel: viewModel)
        button.addTarget(self, action: #selector(self.didTapClose), for: .touchUpInside)
    }

    private lazy var buttonStackView: UIStackView = .build { stackView in
        stackView.distribution = .fillProportionally
        stackView.axis = .horizontal
    }

    private lazy var contentStackView: UIStackView = .build { stackView in
        stackView.distribution = .fill
        stackView.spacing = 10
        stackView.axis = .vertical
    }

    private lazy var scrollView: UIScrollView = .build()

    private lazy var scrollContainer: UIStackView = .build { stackView in
        stackView.axis = .vertical
        stackView.spacing = UX.padding
    }

    private lazy var containerView: ShadowCardView = .build()

    private let scrollViewContent: UIView = .build()

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: Initialization
    init(windowUUID: WindowUUID,
         themeManager: ThemeManager = AppContainer.shared.resolve(),
         notificationCenter: NotificationProtocol = NotificationCenter.default
    ) {
        self.windowUUID = windowUUID
        self.themeManager = themeManager
        self.notificationCenter = notificationCenter
        super.init(nibName: nil, bundle: nil)
        tableView.register(cellType: MicroSurveyTableViewCell.self)
        setupLayout()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupLayout()
        tableView.dataSource = self
        tableView.delegate = self

        listenForThemeChange(view)
        applyTheme()
//
//        let cardModel = ShadowCardViewModel(view: tableView, a11yId: "a11y")
//        containerView.configure(cardModel)
    }

    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        self.viewWillLayoutSubviews()
    }

    private func setupLayout() {
        tableView.translatesAutoresizingMaskIntoConstraints = false
        microSurveyHeaderView.translatesAutoresizingMaskIntoConstraints = false

        buttonStackView.addArrangedSubview(privacyPolicyButton)
        buttonStackView.addArrangedSubview(submitButton)

        scrollContainer.addArrangedSubview(tableView)
        scrollContainer.addArrangedSubview(buttonStackView)
        scrollView.addSubview(scrollContainer)
        view.addSubviews(microSurveyHeaderView, scrollView)
        //        contentStackView.accessibilityElements = [homepageHeaderCell.contentView, privateMessageCardCell]
        //
        NSLayoutConstraint.activate(
            [
                microSurveyHeaderView.topAnchor.constraint(
                    equalTo: view.topAnchor,
                    constant: UX.padding
                ),
                microSurveyHeaderView.leadingAnchor.constraint(
                    equalTo: view.safeAreaLayoutGuide.leadingAnchor,
                    constant: UX.padding
                ),
                microSurveyHeaderView.trailingAnchor.constraint(
                    equalTo: view.safeAreaLayoutGuide.trailingAnchor,
                    constant: -UX.padding
                ),

                scrollView.topAnchor.constraint(
                    equalTo: microSurveyHeaderView.bottomAnchor,
                    constant: UX.padding
                ),
                scrollView.leadingAnchor.constraint(
                    equalTo: view.safeAreaLayoutGuide.leadingAnchor,
                    constant: UX.padding
                ),
                scrollView.trailingAnchor.constraint(
                    equalTo: view.safeAreaLayoutGuide.trailingAnchor,
                    constant: -UX.padding
                ),

                scrollView.bottomAnchor.constraint(
                    equalTo: view.safeAreaLayoutGuide.bottomAnchor,
                    constant: -UX.padding
                ),

                scrollContainer.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor, constant: -UX.padding * 2),

                scrollContainer.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor,
                                                     constant: UX.padding),
                scrollContainer.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor,
                                                        constant: -UX.padding),

                tableView.topAnchor.constraint(equalTo: scrollContainer.topAnchor),
                tableView.leadingAnchor.constraint(equalTo: scrollContainer.leadingAnchor),
                tableView.trailingAnchor.constraint(equalTo: scrollContainer.trailingAnchor),

                tableView.heightAnchor.constraint(equalToConstant: tableView.contentSize.height + 88),

                buttonStackView.topAnchor.constraint(equalTo: tableView.bottomAnchor, constant: 8),
                buttonStackView.leadingAnchor.constraint(equalTo: scrollContainer.leadingAnchor, constant: UX.padding),
                buttonStackView.trailingAnchor.constraint(equalTo: scrollContainer.trailingAnchor, constant: -UX.padding),
            ]
        )
    }

    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return UITableView.automaticDimension
    }

    // MARK: UITableViewDataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return options.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: MicroSurveyTableViewCell.cellIdentifier,
                                                       for: indexPath) as? MicroSurveyTableViewCell else {
            return UITableViewCell()
        }
        cell.configureCell(options[indexPath.row])
        return cell
    }

    // MARK: UITableViewDelegate
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let headerView = tableView.dequeueReusableHeaderFooterView(
            withIdentifier: MicroSurveyTableHeaderView.cellIdentifier
        ) as? MicroSurveyTableHeaderView else { return nil }

        headerView.applyTheme(theme: themeManager.currentTheme(for: windowUUID))
        return headerView
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        (tableView.cellForRow(at: indexPath) as? MicroSurveyTableViewCell)?.checked.toggle()
    }

    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        (tableView.cellForRow(at: indexPath) as? MicroSurveyTableViewCell)?.checked = false
    }

    func applyTheme() {
        let theme = themeManager.currentTheme(for: windowUUID)
        view.backgroundColor = theme.colors.layer1

        microSurveyHeaderView.applyTheme(theme: theme)
        privacyPolicyButton.applyTheme(theme: theme)
        closeButton.applyTheme(theme: theme)
        submitButton.applyTheme(theme: theme)
    }

    override func preferredContentSizeDidChange(forChildContentContainer container: any UIContentContainer) {
        tableView.reloadData()
    }

    private lazy var questionLabel: UILabel = .build { label in
        label.font = FXFontStyles.Regular.body.scaledFont()
        label.text = "How satisfied are you with printing in Firefox?"
        label.numberOfLines = 0
        label.setContentCompressionResistancePriority(.required, for: .vertical)
    }

    let fakespotView: FakespotOptInCardView = .build()

    @objc
    private func didTapSubmit() {
        scrollContainer.removeAllArrangedViews()
        buttonStackView.removeAllArrangedViews()
        buttonStackView.addArrangedSubview(privacyPolicyButton)
        buttonStackView.addArrangedSubview(closeButton)
        scrollContainer.addArrangedSubview(fakespotView)
        scrollContainer.addArrangedSubview(buttonStackView)
        NSLayoutConstraint.activate(
            [
                buttonStackView.topAnchor.constraint(equalTo: fakespotView.bottomAnchor, constant: 8),
                ])
    }

    @objc
    private func didTapClose() {
        store.dispatch(MicroSurveyAction.dismissSurvey(windowUUID.context))
    }

    @objc
    private func didTapPrivacyPolicy() {
        coordinator?.showPrivacyPolicy()
        store.dispatch(MicroSurveyAction.showPrompt(windowUUID.context))
    }
}
