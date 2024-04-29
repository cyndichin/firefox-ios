// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

import Foundation
import Common
import ComponentLibrary

class MicroSurveyViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, Themeable, Notifiable {
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
        tableView.register(MicroSurveyTableHeaderView.self,
                           forHeaderFooterViewReuseIdentifier: MicroSurveyTableHeaderView.cellIdentifier)
        tableView.setContentCompressionResistancePriority(.required, for: .vertical)
        tableView.estimatedRowHeight = 44
        tableView.estimatedSectionHeaderHeight = 100
        tableView.rowHeight = UITableView.automaticDimension
    }

    private lazy var cardContainer: ShadowCardView = .build()

    var options = ["Very Satisfied", "Satisfied", "Neutral", "Dissastified", "Very Dissastified"]

    private enum UX {
        static let titleStackSpacing: CGFloat = 8
        static let padding = NSDirectionalEdgeInsets(
            top: 14,
            leading: 20,
            bottom: -14,
            trailing: -20
        )
    }

    private lazy var microSurveyHeaderView: MicroSurveyHeaderView = {
        let header = MicroSurveyHeaderView()
        header.configure(with: "Complete the survey")
        return header
    }()

    private lazy var privacyPolicyButton: LinkButton = .build { button in
        let privacyPolicyButtonViewModel = LinkButtonViewModel(
            title: "Privacy notice",
            a11yIdentifier: "a11y",
            font: FXFontStyles.Regular.caption2.scaledFont(),
            contentInsets: NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0)
        )
        button.configure(viewModel: privacyPolicyButtonViewModel)
        button.addTarget(self, action: #selector(self.didTapPrivacyPolicy), for: .touchUpInside)
        button.setContentCompressionResistancePriority(.required, for: .vertical)
    }

    private lazy var submitButton: PrimaryRoundedButton = .build { button in
        button.addTarget(self, action: #selector(self.didTapSubmit), for: .touchUpInside)
    }

    private lazy var contentStackView: UIStackView = .build { stackView in
        stackView.distribution = .fill
        stackView.spacing = 10
        stackView.axis = .vertical
    }

    private lazy var scrollView: UIScrollView = .build()

    private lazy var scrollContainer: UIStackView = .build { stackView in
        stackView.axis = .vertical
        stackView.spacing = 21
    }

    private lazy var containerView: UIView = .build { view in
        view.layer.cornerRadius = 16.0
        view.backgroundColor = .white
    }

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
        self.navigationController?.sheetPresentationController?.prefersGrabberVisible = true
        self.sheetPresentationController?.prefersGrabberVisible = true
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
        setupNotifications(forObserver: self, observing: [.DynamicFontChanged])
    }

    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        self.viewWillLayoutSubviews()
    }

    private func setupLayout() {
        let viewModel = PrimaryRoundedButtonViewModel(
            title: "Submit",
            a11yIdentifier: "a11y"
        )
        submitButton.configure(viewModel: viewModel)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        microSurveyHeaderView.translatesAutoresizingMaskIntoConstraints = false

        containerView.addSubviews(tableView)
        scrollContainer.addArrangedSubview(containerView)
        scrollContainer.addArrangedSubview(submitButton)
        scrollContainer.addArrangedSubview(privacyPolicyButton)
        scrollView.addSubview(scrollContainer)
        view.addSubviews(microSurveyHeaderView, scrollView)
        //        contentStackView.accessibilityElements = [homepageHeaderCell.contentView, privateMessageCardCell]
        //
        NSLayoutConstraint.activate(
            [
                microSurveyHeaderView.topAnchor.constraint(
                    equalTo: view.topAnchor,
                    constant: UX.padding.top
                ),
                microSurveyHeaderView.leadingAnchor.constraint(
                    equalTo: view.safeAreaLayoutGuide.leadingAnchor,
                    constant: UX.padding.leading
                ),
                microSurveyHeaderView.trailingAnchor.constraint(
                    equalTo: view.safeAreaLayoutGuide.trailingAnchor,
                    constant: UX.padding.trailing
                ),

                scrollView.topAnchor.constraint(
                    equalTo: microSurveyHeaderView.bottomAnchor
                ),
                scrollView.leadingAnchor.constraint(
                    equalTo: view.safeAreaLayoutGuide.leadingAnchor
                ),
                scrollView.trailingAnchor.constraint(
                    equalTo: view.safeAreaLayoutGuide.trailingAnchor
                ),

                scrollView.bottomAnchor.constraint(
                    equalTo: view.safeAreaLayoutGuide.bottomAnchor,
                    constant: UX.padding.bottom
                ),

                scrollContainer.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: UX.padding.top),
                scrollContainer.leadingAnchor.constraint(
                    equalTo: view.safeAreaLayoutGuide.leadingAnchor,
                    constant: UX.padding.leading
                ),
                scrollContainer.trailingAnchor.constraint(
                    equalTo: view.safeAreaLayoutGuide.trailingAnchor,
                    constant: UX.padding.trailing
                ),
                scrollContainer.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: UX.padding.bottom),
                tableView.heightAnchor.constraint(equalToConstant: tableView.contentSize.height + 88),

                tableView.topAnchor.constraint(equalTo: containerView.topAnchor),
                tableView.leadingAnchor.constraint(
                    equalTo: containerView.leadingAnchor,
                    constant: UX.padding.leading
                ),
                tableView.trailingAnchor.constraint(
                    equalTo: containerView.trailingAnchor,
                    constant: UX.padding.trailing
                ),

                tableView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
                privacyPolicyButton.centerXAnchor.constraint(equalTo: containerView.centerXAnchor)
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
        containerView.layer.borderColor = theme.colors.borderPrimary.cgColor
        containerView.layer.borderWidth = 1
        microSurveyHeaderView.applyTheme(theme: theme)
        privacyPolicyButton.applyTheme(theme: theme)
        submitButton.applyTheme(theme: theme)
    }

    private func adjustLayout() {
//        let isA11ySize = UIApplication.shared.preferredContentSizeCategory.isAccessibilityCategory
//        if isA11ySize {
//            self.sheetPresentationController?.selectedDetentIdentifier = .large
//        } else {
//            self.sheetPresentationController?.selectedDetentIdentifier = .medium
//        }
    }

    func handleNotifications(_ notification: Notification) {
        switch notification.name {
        case .DynamicFontChanged:
            adjustLayout()
        case UIContentSizeCategory.didChangeNotification:
            adjustLayout()
        default: break
        }
    }

    private lazy var questionLabel: UILabel = .build { label in
        label.font = FXFontStyles.Regular.body.scaledFont()
        label.text = "How satisfied are you with printing in Firefox?"
        label.numberOfLines = 0
        label.setContentCompressionResistancePriority(.required, for: .vertical)
    }

    private lazy var headerLabel: UILabel = .build { label in
        label.font = FXFontStyles.Regular.headline.scaledFont()
        label.numberOfLines = 0
        label.adjustsFontForContentSizeCategory = true
//        label.accessibilityIdentifier = a11y.title
        label.accessibilityTraits.insert(.header)
        label.text = "Thanks for the feedback!"
    }

    @objc
    private func didTapSubmit() {
        microSurveyHeaderView.configure(with: "Survey complete")
        tableView
        containerView.addSubview(headerLabel)
        NSLayoutConstraint.activate(
            [
                headerLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 8),
                headerLabel.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -8),
                headerLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 8),
                headerLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -8),
            ])
    }

    @objc
    private func didTapClose() {
        store.dispatch(MicroSurveyAction.dismissSurvey(windowUUID.context))
    }

    @objc
    private func didTapPrivacyPolicy() {
        coordinator?.showPrivacyPolicy()
        store.dispatch(MicroSurveyAction.dismissSurvey(windowUUID.context))
    }
}
