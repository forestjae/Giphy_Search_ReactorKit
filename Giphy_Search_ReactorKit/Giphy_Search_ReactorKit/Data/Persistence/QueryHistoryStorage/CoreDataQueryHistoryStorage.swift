//
//  CoreDataQueryHistoryStorage.swift
//  Giphy_Search_RxSwift
//
//  Created by Lee Seung-Jae on 2022/10/24.
//

import Foundation
import RxSwift

class CoreDataQueryHistoryStorage: QueryHistoryStorage {
    private let coreDataProvider: CoreDataProvider

    init(coreDataProvider: CoreDataProvider = CoreDataProvider.shared) {
        self.coreDataProvider = coreDataProvider
    }

    func fetchQuery() -> Single<[String]> {
        let sort = NSSortDescriptor(key: "createdAt", ascending: false)
        let request = Query.fetchRequest()
        request.sortDescriptors = [sort]

        return Single.create { single in
            do {
                let result = try self.coreDataProvider.fetch(request: request)
                    .compactMap { $0.query }
                single(.success(result))
            } catch let error {
                print(error)
                single(.failure(error))
            }
            return Disposables.create()
        }
    }

    func saveQuery(of query: String, createdAt: Date = Date()) -> Single<String> {
        let predicate = NSPredicate(format: "query == %@", query)

        return Single.create { single in
            do {
                let objects = try self.coreDataProvider.fetch(
                    request: Query.fetchRequest(),
                    predicate: predicate
                )

                if let object = objects.first {
                    try self.coreDataProvider.update(
                        object: object,
                        values:  ["query" : query, "createdAt": createdAt]
                    )
                } else {
                    try self.coreDataProvider.create(
                        entityName: String(describing: Query.self),
                        values: ["query" : query, "createdAt": createdAt]
                    )
                }
                single(.success(query))
            } catch let error {
                single(.failure(error))
            }

            return Disposables.create()
        }
    }

    func removeQuery(of query: String) -> Single<String> {
        let predicate = NSPredicate(format: "query == %@", query)

        return Single.create { single in
            do {
                let objects = try self.coreDataProvider.fetch(
                    request: Query.fetchRequest(),
                    predicate: predicate
                )
                try objects.forEach {
                    try self.coreDataProvider.delete(object: $0)
                }
                single(.success(query))
            } catch let error {
                single(.failure(error))
            }
            return Disposables.create()
        }
    }
}
