// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

import Foundation
import Common
import ComponentLibrary
import UIKit

final class PrivateHomepageViewController: UIViewController, ContentContainable, Themeable {
    // MARK: ContentContainable Variables
    var contentType: ContentType = .privateHomepage

    // MARK: Theming Variables
    var themeManager: Common.ThemeManager
    var themeObserver: NSObjectProtocol?
    var notificationCenter: Common.NotificationProtocol

    private let logger: Logger
    private let viewModel: PrivateHomepageViewModel
    private let privateHomepageSectionManager = PrivateHomepageSectionManager()

    private var dataSource: UICollectionViewDiffableDataSource<PrivateHomepageViewModel.Section, PrivateHomepageViewModel.Item>?

    private lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: createLayout())
        collectionView.register(HomeLogoHeaderCell.self, forCellWithReuseIdentifier: HomeLogoHeaderCell.cellIdentifier)
        collectionView.register(PrivateMessageCardCell.self, forCellWithReuseIdentifier: PrivateMessageCardCell.cellIdentifier)

        collectionView.keyboardDismissMode = .onDrag
        collectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        collectionView.backgroundColor = .clear
        return collectionView
    }()

    private lazy var gradient: CAGradientLayer = {
        let gradient = CAGradientLayer()
        gradient.type = .axial
        gradient.startPoint = CGPoint(x: 1, y: 0)
        gradient.endPoint = CGPoint(x: 0, y: 1)
        gradient.locations = [0, 0.5, 1]
        return gradient
    }()

    init(themeManager: ThemeManager = AppContainer.shared.resolve(),
         notificationCenter: NotificationProtocol = NotificationCenter.default,
         logger: Logger = DefaultLogger.shared
    ) {
        self.themeManager = themeManager
        self.notificationCenter = notificationCenter
        self.logger = logger
        self.viewModel = PrivateHomepageViewModel(theme: themeManager.currentTheme)
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        configureCollectionView()
        configureDataSource()

        listenForThemeChange(view)
        applyTheme()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        gradient.frame = view.bounds
    }

    // MARK: Layout
    private func configureCollectionView() {
        view.layer.addSublayer(gradient)
        view.addSubview(collectionView)

        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
    }

    private func createLayout() -> UICollectionViewLayout {
        let layout = UICollectionViewCompositionalLayout { [weak self] (sectionIndex: Int, layoutEnvironment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection? in
            guard let self, let section = PrivateHomepageViewModel.Section(rawValue: sectionIndex) else {
                self?.logger.log("Private Homepage - Unable to create layout for section", level: .debug, category: .homepage)
                return nil
            }

            switch section {
            case .logo:
                return self.privateHomepageSectionManager.logoSection(layoutEnvironment: layoutEnvironment)
            case .messageCard:
                return self.privateHomepageSectionManager.messageCardSection(layoutEnvironment: layoutEnvironment)
            }
        }
        return layout
    }

    // MARK: Data Source
    private func configureDataSource() {
        dataSource = UICollectionViewDiffableDataSource<PrivateHomepageViewModel.Section, PrivateHomepageViewModel.Item>(collectionView: collectionView) { collectionView, indexPath, item in
            return self.makeCellFor(item, at: indexPath)
        }

        buildSnapshot()
    }

    private func makeCellFor(_ item: PrivateHomepageViewModel.Item, at indexPath: IndexPath) -> UICollectionViewCell {
        switch item {
        case .logo:
            guard let logoHeaderCell = collectionView.dequeueReusableCell(cellType: HomeLogoHeaderCell.self, for: indexPath) else {
                self.logger.log("Private Homepage - Unable to retrieve HomeLogoHeaderCell, default to UICollectionViewCell", level: .debug, category: .homepage)
                return UICollectionViewCell()
            }

            logoHeaderCell.applyTheme(theme: self.themeManager.currentTheme)
            return logoHeaderCell

        case .messageCard(let details):
            guard let privateMessageCardCell = collectionView.dequeueReusableCell(cellType: PrivateMessageCardCell.self, for: indexPath) else {
                self.logger.log("Private Homepage - Unable to retrieve PrivateMessageCardCell, default to UICollectionViewcCell", level: .debug, category: .homepage)
                return UICollectionViewCell()
            }

            privateMessageCardCell.configure(with: details, and: self.themeManager.currentTheme)
            return privateMessageCardCell
        }
    }

    private func buildSnapshot() {
        var snapshot = NSDiffableDataSourceSnapshot<PrivateHomepageViewModel.Section, PrivateHomepageViewModel.Item>()

        snapshot.appendSections([.logo, .messageCard])
        snapshot.appendItems([.logo], toSection: .logo)
        snapshot.appendItems([.messageCard(viewModel.messageCardViewModel)],
                             toSection: .messageCard)

        dataSource?.apply(snapshot, animatingDifferences: true)
    }

    // MARK: Theming
    func applyTheme() {
        let theme = themeManager.currentTheme
        gradient.colors = theme.colors.layerHomepage.cgColors
    }
}
