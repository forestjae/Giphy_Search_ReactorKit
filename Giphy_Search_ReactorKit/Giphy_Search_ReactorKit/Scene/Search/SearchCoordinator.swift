//
//  SearchCoordinator.swift
//  Giphy_Search_ReactorKit
//
//  Created by Lee Seung-Jae on 2022/11/07.
//

import RxSwift
import UIKit

final class SearchCoordinator: Coordinator<Void> {
    private let navigationController: UINavigationController

    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }

    override func start() -> Observable<Void> {
        let searchReactor = SearchReactor(
            coordinator: self,
            gifSearchUseCase: DefaultGIFSearchUseCase(
                gifRepository: DefaultGIFRepository(
                    networkProvider: DefaultNetworkProvider()
                )
            ),
            queryHistoryUseCase: DefaultQueryHistoryUseCase(
                queryHistoryRepository: DefaultQueryHistoryRepository(
                    queryHistoryStorage: CoreDataQueryHistoryStorage()
                )
            )
        )
        let searchViewController = SearchViewController(reactor: searchReactor)
        
        self.navigationController.setViewControllers([searchViewController], animated: true)

        return Observable.never()
    }
}
