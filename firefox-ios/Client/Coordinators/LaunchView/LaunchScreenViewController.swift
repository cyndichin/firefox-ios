// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

import Common
import Foundation

class LaunchScreenViewController: UIViewController, LaunchFinishedLoadingDelegate, FeatureFlaggable {
    private lazy var launchScreen = LaunchScreenView.fromNib()
    private weak var coordinator: LaunchFinishedLoadingDelegate?
    private var viewModel: LaunchScreenViewModel
    private var mainQueue: DispatchQueueInterface

    private lazy var splashScreenAnimation = SplashScreenAnimation()
    private let nimbusSplashScreenFeatureLayer = NimbusSplashScreenFeatureLayer()
    private var hasExperimentsFetched = false
    private var splashScreenTask: Task<Void, Never>?
    private let profile: Profile = AppContainer.shared.resolve()

    init(coordinator: LaunchFinishedLoadingDelegate,
         viewModel: LaunchScreenViewModel = LaunchScreenViewModel(),
         mainQueue: DispatchQueueInterface = DispatchQueue.main) {
        self.coordinator = coordinator
        self.viewModel = viewModel
        self.mainQueue = mainQueue
        super.init(nibName: nil, bundle: nil)
        viewModel.delegate = self

        NotificationCenter.default.addObserver(
            forName: .nimbusExperimentsFetched,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.splashScreenTask?.cancel()
            self?.hasExperimentsFetched = true
            print("DID STARTY LOADING \(self?.splashScreenTask?.isCancelled)")
        }
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }

    required init?(coder: NSCoder) {
        fatalError()
    }

    // MARK: - View cycles

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground

        // Initialize the feature flag subsystem.
        // Among other things, it toggles on and off Nimbus, Contile, Adjust.
        // i.e. this must be run before initializing those systems.
        LegacyFeatureFlagsManager.shared.initializeDeveloperFeatures(with: profile)

//        setupDependencies()
//        delayStart()

        Task {
            setupDependencies()
            await delayStart()
            await startLoading()
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupLaunchScreen()
    }

    // MARK: - Loading
    func startLoading() async {
        await viewModel.startLoading()
    }

    // MARK: - Setup

    private func setupLayout() {
        launchScreen.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(launchScreen)

        NSLayoutConstraint.activate([
            launchScreen.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            launchScreen.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            launchScreen.topAnchor.constraint(equalTo: view.topAnchor),
            launchScreen.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    // MARK: - LaunchFinishedLoadingDelegate

    func launchWith(launchType: LaunchType) {
        mainQueue.async {
            self.coordinator?.launchWith(launchType: launchType)
        }
    }

    func launchBrowser() {
        mainQueue.async {
            self.coordinator?.launchBrowser()
        }
    }

    private func setupDependencies() {

        let appLaunchUtil = AppLaunchUtil(profile: profile)
        appLaunchUtil.setUpPreLaunchDependencies()
    }

    // MARK: - Splash Screen

    private func delayStart() async {
        guard featureFlags.isFeatureEnabled(.splashScreen, checking: .buildOnly), hasExperimentsFetched else { return }
        let position: Int = nimbusSplashScreenFeatureLayer.maximumDurationMs
        splashScreenTask?.cancel()
        splashScreenTask = Task {
            try? await Task.sleep(nanoseconds: UInt64(position * 1_000_000_000))
            try? Task.checkCancellation()
        }
        await splashScreenTask?.value
    }

    private func setupLaunchScreen() {
        setupLayout()
        guard featureFlags.isFeatureEnabled(.splashScreen, checking: .buildOnly) else { return }
        if !UIAccessibility.isReduceMotionEnabled {
            splashScreenAnimation.configureAnimation(with: launchScreen)
        }
    }
}
