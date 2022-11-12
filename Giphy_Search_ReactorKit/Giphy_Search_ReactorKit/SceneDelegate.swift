//
//  SceneDelegate.swift
//  Giphy_Search_ReactorKit
//
//  Created by Lee Seung-Jae on 2022/09/09.
//

import UIKit
import RxSwift

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?

    private let disposebag = DisposeBag()

    func scene(
        _ scene: UIScene,
        willConnectTo session: UISceneSession,
        options connectionOptions: UIScene.ConnectionOptions
    ) {
        guard let windowScene = (scene as? UIWindowScene) else { return }

        self.window = UIWindow(windowScene: windowScene)

        guard let window = window else {
            return
        }

        let appCoordinator = AppCoordinator(window: window)
        appCoordinator.start()
            .subscribe()
            .disposed(by: self.disposebag)
    }
}
