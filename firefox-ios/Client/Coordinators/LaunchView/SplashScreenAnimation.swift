// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

import Foundation
import Lottie
import UIKit
import SwiftUI

// Animation for when the user launches the app on fresh install
struct SplashScreenAnimation {
    private let animationView: LottieAnimationView
    enum UX {
        static let size = 130
    }

    init() {
        animationView = LottieAnimationView(name: "splashScreen.json")
    }

    /// Determines which animation type to display depending on device orientation
    /// Check whether device is a phone and if not, we check if top tabs are shown, otherwise we default to phone mode
    /// - Parameter showsTopTabs: true or false if top tabs is shown
    /// - Returns: data clearance animation type
    func setupAnimation(with view: UIView) {
        animationView.contentMode = .scaleAspectFit
        animationView.loopMode = .loop
        animationView.backgroundColor = .systemBackground

        animationView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(animationView)
        NSLayoutConstraint.activate([
            animationView.heightAnchor.constraint(equalToConstant: CGFloat(UX.size)),
            animationView.widthAnchor.constraint(equalToConstant: CGFloat(UX.size)),
            animationView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            animationView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
        ])
    }

    func playAnimation(with view: UIView) {
        animationView.play { _ in
            UIView.animate(
                withDuration: 0.3,
                animations: {
                    self.animationView.alpha = 0
                },
                completion: { _ in
                    self.animationView.isHidden = true
                    self.animationView.removeFromSuperview()
                }
            )
        }
    }
}
