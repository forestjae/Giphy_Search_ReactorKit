//
//  Coordinator.swift
//  Giphy_Search_ReactorKit
//
//  Created by Lee Seung-Jae on 2022/11/07.
//

import Foundation
import RxSwift

class Coordinator<CoordinationResult>: NSObject {
    let identifer = UUID()
    var childCoordinators = [UUID: Any]()

    private func store<T>(coordinator: Coordinator<T>) {
        self.childCoordinators[coordinator.identifer] = coordinator
    }

    private func release<T>(coordinator: Coordinator<T>) {
        self.childCoordinators[coordinator.identifer] = nil
    }

    func coordinate<T>(to coordinator: Coordinator<T>) -> Observable<T> {
        self.store(coordinator: coordinator)
        return coordinator.start()
            .do(onNext: {[weak self] _ in
                self?.release(coordinator: coordinator)
            })
    }

    func start() -> Observable<CoordinationResult> {
        fatalError("not implemented")
    }
}
