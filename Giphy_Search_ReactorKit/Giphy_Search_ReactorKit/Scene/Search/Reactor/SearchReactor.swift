//
//  SearchReactor.swift
//  Giphy_Search_ReactorKit
//
//  Created by Lee Seung-Jae on 2022/11/07.
//

import Foundation
import RxSwift
import ReactorKit
import RxCocoa

final class SearchReactor: Reactor {
    let initialState: State

    private let coordinator: SearchCoordinator
    private let queryHistoryUseCase: QueryHistoryUseCase
    private let gifSearchUseCase: GIFSearchUseCase

    enum Action {
        case refresh
        case updateQuery(String)
        case searchSessionBegin
        case updateSearchScope(Int)
        case loadNextPage
        case itemDidSelect(IndexPath)
        case queryHistoryDidSelect(IndexPath)
    }

    enum Mutation {
        case setQuery(String)
        case setGIFType(GIFType)
        case queryHistoryUpdated([String])
        case updateImages([GIF], offset: Int, hasNextPage: Bool)
        case setLoadingNextPage(Bool)
    }

    struct State {
        var query: String?
        var imagesSearched: [GIFItemReactor] = [] 
        var gifType: GIFType = .gif
        var queryHistory: [String] = []
        var nextOffset: Int = 0
        var hasNextpage: Bool = false
        var isLoadingNextPage: Bool = false
    }

    init(
        coordinator: SearchCoordinator,
        gifSearchUseCase: GIFSearchUseCase,
        queryHistoryUseCase: QueryHistoryUseCase
    ) {
        self.coordinator = coordinator
        self.gifSearchUseCase = gifSearchUseCase
        self.queryHistoryUseCase = queryHistoryUseCase
        self.initialState = State()
    }

    func mutate(action: Action) -> Observable<Mutation> {
        let currentState = self.currentState
        switch action {
        case .refresh:
            return self.queryHistoryUseCase.fetchQueryHistory()
                .asObservable()
                .map { .queryHistoryUpdated($0) }
        case .updateQuery(let query):
            return Observable.just(.setQuery(query))
        case .searchSessionBegin:
            guard let query = currentState.query, query != "" else {
                return Observable.empty()
            }
            return Observable.concat([
                self.gifSearchUseCase.searchGIFImages(type: currentState.gifType, query: query, offset: 0)
                    .asObservable()
                    .map { .updateImages($0.gifs, offset: $0.offset, hasNextPage: $0.hasNextPage) },
                self.queryHistoryUseCase.saveQuery(of: query)
                    .flatMap { _ in self.queryHistoryUseCase.fetchQueryHistory() }
                    .asObservable()
                    .map { .queryHistoryUpdated($0) }
            ])
        case .loadNextPage:
            guard let query = currentState.query,
                  query != "",
                  !self.currentState.isLoadingNextPage
            else {
                return Observable.empty()
            }
            return Observable.concat([
                Observable.just(.setLoadingNextPage(true)),
                self.gifSearchUseCase.searchGIFImages(
                type: currentState.gifType,
                query: query,
                offset: self.currentState.nextOffset
            )
                .asObservable()
                .map { .updateImages($0.gifs, offset: $0.offset, hasNextPage: $0.hasNextPage) },
                Observable.just(.setLoadingNextPage(false))
            ])
        case .itemDidSelect(let indexPath):
            return Observable.empty()
        case .queryHistoryDidSelect(let indexPath):
            let query = self.currentState.queryHistory[indexPath.row]
            return Observable.concat([
                self.gifSearchUseCase.searchGIFImages(type: currentState.gifType, query: query, offset: 0)
                    .asObservable()
                    .map { .updateImages($0.gifs, offset: $0.offset, hasNextPage: $0.hasNextPage) },
                self.queryHistoryUseCase.saveQuery(of: query)
                    .flatMap { _ in self.queryHistoryUseCase.fetchQueryHistory() }
                    .asObservable()
                    .map { .queryHistoryUpdated($0) }
            ])
        case .updateSearchScope(let scope):
            guard let gifType = GIFType(index: scope) else {
                return Observable.empty()
            }
            return .just(.setGIFType(gifType))
        }
    }

    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        switch mutation {
        case .setQuery(let query):
            newState.query = query
            return newState
        case .updateImages(let images, let offset, let hasNextPage):
            if offset == 0 {
                newState.imagesSearched = images.map { GIFItemReactor.init(image: $0) }
            } else {
                newState.imagesSearched += images.map { GIFItemReactor.init(image: $0) }
            }

            newState.nextOffset = offset + 10
            newState.hasNextpage = hasNextPage
            return newState
        case .setGIFType(let gifType):
            newState.gifType = gifType
            return newState
        case .queryHistoryUpdated(let queries):
            newState.queryHistory = queries
            return newState
        case .setLoadingNextPage(let isLoadingNextPage):
            newState.isLoadingNextPage = isLoadingNextPage
            return newState
        }
    }
}

// MARK: - Search Section/Item

enum SearchSection: Int {
    case searchResult = 0

    var title: String {
        switch self {
        case .searchResult:
            return "All The GIFs"
        }
    }
}

enum SearchItem: Hashable {
    case image(GIFItemReactor)
}


// MARK: - SearchGuide Section/Item

enum SearchGuideSection: Int {
    case searchHistory = 0

    var title: String {
        switch self {
        case .searchHistory:
            return "Recent Searches"
        }
    }
}

enum SearchGuideItem: Hashable {
    case searchQueryHistory(String)
}
