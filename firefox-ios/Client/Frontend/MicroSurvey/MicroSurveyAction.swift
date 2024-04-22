// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

import Foundation
import Redux

struct MicroSurveyState: ScreenState, Equatable {
    var isPromptShown: Bool
    var isSurveyShown: Bool
    var windowUUID: WindowUUID

    init(windowUUID: WindowUUID) {
        self.windowUUID = windowUUID
        self.isPromptShown = false
        self.isSurveyShown = false
    }

    static let reducer: Reducer<Self> = { state, action in
        // Only process actions for the current window
        guard action.windowUUID == .unavailable || action.windowUUID == state.windowUUID else { return state }

        switch action {
        case MicroSurveyAction.showPrompt:
            var state = state
            state.isPromptShown = true
            state.isSurveyShown = false
            return state

        case MicroSurveyAction.dismissPrompt:
            var state = state
            state.isPromptShown = false
            state.isSurveyShown = false
            return state

        case MicroSurveyAction.showSurvey:
            var state = state
            state.isSurveyShown = true
            return state
        case MicroSurveyAction.dismissSurvey:
            var state = state
            state.isSurveyShown = false
            return state
        default:
            return state
        }
    }
}

enum MicroSurveyAction: Action {
    var windowUUID: UUID {
        switch self {
        case .showPrompt(let context), .dismissPrompt(let context), .showSurvey(let context), .dismissSurvey(let context):
            return context.windowUUID
        }
    }

    case showPrompt(ActionContext)
    case dismissPrompt(ActionContext)
    case showSurvey(ActionContext)
    case dismissSurvey(ActionContext)
}
