// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

import Foundation

protocol SectionManager {
    func layoutSection(_ layoutEnvironment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection
}

final class PrivateHomepageSectionManager {
    struct UX {
        static let logoBottomSpacing: CGFloat = 30
        static let spacingBetweenSections: CGFloat = 24
    }

    func logoSection(layoutEnvironment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection? {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1),
                                              heightDimension: .estimated(100))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)

        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1),
                                               heightDimension: .estimated(100))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitem: item, count: 1)

        let horizontalInset = HomepageViewModel.UX.leadingInset(traitCollection: layoutEnvironment.traitCollection)

        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = NSDirectionalEdgeInsets(top: 0,
                                                        leading: horizontalInset,
                                                        bottom: 0,
                                                        trailing: horizontalInset)
        return section
    }

    func messageCardSection(layoutEnvironment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1),
                                              heightDimension: .estimated(180))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)

        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1),
                                               heightDimension: .estimated(180))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitem: item, count: 1)

        let horizontalInset = HomepageViewModel.UX.leadingInset(traitCollection: layoutEnvironment.traitCollection)

        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = NSDirectionalEdgeInsets(top: UX.spacingBetweenSections,
                                                        leading: horizontalInset,
                                                        bottom: 0,
                                                        trailing: horizontalInset)
        return section
    }
}
