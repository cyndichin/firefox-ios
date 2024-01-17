// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

import Foundation
import Lottie
import UIKit
import SwiftUI

public enum FirefoxAnimation {
    case deletion

    public func name() -> String {
        switch self {
        case .deletion:
            return "deletion.json"
        }
    }

    public func animation() -> LottieAnimation? {
        guard let animation = LottieAnimation.named(self.name()) else {
            print("WROMNG DIRECTIONR")
            return nil
        }
        return animation
    }

    public func setup() -> UIView {
        let animationView = LottieAnimationView()
        let animation = FirefoxAnimation.deletion.animation()
        animationView.animation = animation
        animationView.contentMode = .scaleAspectFill
        animationView.loopMode = .playOnce
        animationView.play { _ in
            animationView.removeFromSuperview()
        }
        return animationView
    }
}
