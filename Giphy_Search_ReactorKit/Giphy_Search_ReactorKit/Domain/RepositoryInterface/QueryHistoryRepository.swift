//
//  QueryHistoryRepository.swift
//  Giphy_Search_RxSwift
//
//  Created by Lee Seung-Jae on 2022/10/23.
//

import Foundation
import RxSwift

protocol QueryHistoryRepository {
    func fetchQueryHistory() -> Single<[String]>

    func saveQuery(of query: String, createdAt date: Date) -> Single<String>

    func removeQuery(of query: String) -> Single<String>
}
