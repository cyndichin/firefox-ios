// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

import UIKit

/// The view model used to configure a `CloseButton`
public struct CloseButtonViewModel {
    public let a11yIdentifier: String
    public let a11yLabel: String

    public init(a11yIdentifier: String, a11yLabel: String) {
        self.a11yIdentifier = a11yIdentifier
        self.a11yLabel = a11yLabel
    }
}
