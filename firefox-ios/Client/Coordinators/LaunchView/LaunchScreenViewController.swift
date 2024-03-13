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
//            self?.hasExperimentsFetched = true
            print("CYN: fetched experiments \(self?.splashScreenTask?.isCancelled)")
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
        print("CYN: LAUNCH SCREEN LOADED")
        view.backgroundColor = .systemBackground

        Task {
            await startExperiments()
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

    private func startExperiments() async {
        guard featureFlags.isFeatureEnabled(.splashScreen, checking: .buildOnly) else { return }
        async let setupDependencies: Void = setupDependencies()
        async let delayStart: Void = delayStart()
        (_, _) = await (setupDependencies, delayStart)
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

    private func setupDependencies() async {
        let appLaunchUtil = AppLaunchUtil(profile: profile)
        appLaunchUtil.setUpPreLaunchDependencies()
        appLaunchUtil.setUpPostLaunchDependencies()
    }

    // MARK: - Splash Screen

    private func delayStart() async {
        let position: Int = nimbusSplashScreenFeatureLayer.maximumDurationMs
        splashScreenTask?.cancel()
        splashScreenTask = Task {
            try? await Task.sleep(nanoseconds: UInt64(position * 1_000_000))
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
