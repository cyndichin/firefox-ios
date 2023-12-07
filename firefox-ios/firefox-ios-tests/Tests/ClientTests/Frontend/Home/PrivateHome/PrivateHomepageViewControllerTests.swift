// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

import XCTest
@testable import Client

final class PrivateHomepageViewControllerTests: XCTestCase {
    override func setUp() {
        super.setUp()
    }

    override func tearDown() {
        super.tearDown()
    }

    func testPrivateHomepageViewController_simpleCreation_hasNoLeaks() {
        let privateHomeViewController = PrivateHomepageViewController()
        trackForMemoryLeaks(privateHomeViewController)
        XCTAssertEqual(privateHomeViewController.contentType, .privateHomepage)
    }
}
