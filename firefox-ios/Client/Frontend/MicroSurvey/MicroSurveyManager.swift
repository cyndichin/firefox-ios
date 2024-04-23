// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

import Foundation

protocol MobileMessageSurfaceProtocol {
    func handleMessageDisplayed()
    func handleMessagePressed()
    func handleMessageDismiss()
}

class MicroSurveyManager: MobileMessageSurfaceProtocol {
    private var message: GleanPlumbMessage?
    private var messagingManager: GleanPlumbMessageManagerProtocol

    private let windowUUID: WindowUUID
    var currentWindowUUID: UUID? { windowUUID }

    init(windowUUID: WindowUUID, messagingManager: GleanPlumbMessageManagerProtocol = Experiments.messaging
    ) {
        self.messagingManager = messagingManager
        self.windowUUID = windowUUID
        updateMessage()
    }

    // MARK: - Functionality
    /// Checks whether a message exists, and is not expired, and attempts to
    /// build a `MicroSurveyViewPrompt` to be presented.
    func showMicroSurveySurface() -> MicroSurveyPromptView? {
        guard let title = message?.title, let buttonText = message?.buttonLabel, let text = message?.text else {
            return nil
        }
        store.dispatch(MicroSurveyAction.showPrompt(windowUUID.context))

        let viewModel = MicroSurveyViewModel(
            title: title,
            buttonText: buttonText,
            openAction: {
                store.dispatch(MicroSurveyAction.pressedPromptButton(self.windowUUID.context))
            }) {
                store.dispatch(MicroSurveyAction.dismissPrompt(self.windowUUID.context))
            }
//        handleMessageDisplayed()
        let int = messagingManager.getImpressionCount(for: .microsurvey)
        return MicroSurveyPromptView(viewModel: viewModel)
    }

    private func updateMessage() {
        guard message == nil else { return }
        message = messagingManager.getNextMessage(for: .microsurvey)
    }

    // MARK: - MobileMessageSurfaceProtocol
    func handleMessageDisplayed() {
        message.map(messagingManager.onMessageDisplayed)
    }

    func handleMessagePressed() {
        message.map(messagingManager.onMessagePressed)
    }

    func handleMessageDismiss() {
        message.map(messagingManager.onMessageDismissed)
    }
}
