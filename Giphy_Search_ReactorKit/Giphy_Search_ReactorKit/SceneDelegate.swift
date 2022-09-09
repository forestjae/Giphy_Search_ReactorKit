//
//  SceneDelegate.swift
//  Giphy_Search_ReactorKit
//
//  Created by Lee Seung-Jae on 2022/09/09.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?

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

        let vc = ViewController()
        window.rootViewController = vc
        window.makeKeyAndVisible()
    }
}
