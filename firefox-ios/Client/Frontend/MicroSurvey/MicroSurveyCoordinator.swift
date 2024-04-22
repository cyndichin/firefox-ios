// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

import Common
import Foundation
import Shared

protocol MicroSurveyCoordinatorDelegate: AnyObject {
    func showPrivacyPolicy()
}

class MicroSurveyCoordinator: BaseCoordinator, FeatureFlaggable, MicroSurveyCoordinatorDelegate {
    weak var parentCoordinator: ParentCoordinatorDelegate?
    private var profile: Profile
    private let tabManager: TabManager
    private var windowUUID: WindowUUID { return tabManager.windowUUID }

    init(router: Router,
         profile: Profile = AppContainer.shared.resolve(),
         tabManager: TabManager) {
        self.tabManager = tabManager
        self.profile = profile
        super.init(router: router)
    }

    func start() {
        let microSurveyViewController = MicroSurveyViewController(windowUUID: windowUUID)
        microSurveyViewController.coordinator = self
        microSurveyViewController.sheetPresentationController?.detents = [.medium()]
        let controller = DismissableNavigationViewController(rootViewController: microSurveyViewController)
        microSurveyViewController.sheetPresentationController?.selectedDetentIdentifier = .medium

        controller.sheetPresentationController?.selectedDetentIdentifier = .medium

        router.setRootViewController(microSurveyViewController, hideBar: true)
    }

    func showPrivacyPolicy() {
        guard let url = URL(string: "https://www.mozilla.org/privacy/firefox") else { return }
        tabManager.addTabsForURLs([url], zombie: false, shouldSelectTab: true)
        self.router.dismiss(animated: true)
    }

    func dismissModal(animated: Bool) {
        router.dismiss(animated: animated, completion: nil)
        parentCoordinator?.didFinish(from: self)
    }

    @objc
    func tapButton() {
        self.router.dismiss(animated: true)
    }
}
