// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

import Foundation
import Common
import Shared

class PrivateHomepageViewModel {
    enum Section: Int {
        case logo
        case messageCard
    }

    enum Item: Hashable {
        case logo
        case messageCard(PrivateMessageCardCell.PrivateMessageCard)
    }

    private var theme: Theme

    init(theme: Theme) {
        self.theme = theme
    }

    var homoLogoHeaderViewModel: HomeLogoHeaderViewModel {
        return HomeLogoHeaderViewModel(theme: theme)
    }

    var messageCardViewModel: PrivateMessageCardCell.PrivateMessageCard {
        return PrivateMessageCardCell.PrivateMessageCard(
            title: .FirefoxHomepage.FeltPrivacyUI.Title,
            body: String(format: .FirefoxHomepage.FeltPrivacyUI.Body, AppName.shortName.rawValue),
            link: .FirefoxHomepage.FeltPrivacyUI.Link
        )
    }
}
