//
//  AppCoordinator.swift
//  Giphy_Search_ReactorKit
//
//  Created by Lee Seung-Jae on 2022/11/08.
//

import UIKit
import RxSwift

final class AppCoordinator: Coordinator<Void> {
    var window: UIWindow

    init(window: UIWindow) {
        self.window = window
    }

    override func start() -> Observable<Void> {
        let navigationController = UINavigationController()
        
        window.rootViewController = navigationController
        window.makeKeyAndVisible()

        return self.searchFlow(navigationController: navigationController)
    }

    private func searchFlow(navigationController: UINavigationController) -> Observable<Void> {
        let searchCoordinator = SearchCoordinator(navigationController: navigationController)
        return self.coordinate(to: searchCoordinator)
    }
}
