//
//  SearchViewController.swift
//  Giphy_Search_ReactorKit
//
//  Created by Lee Seung-Jae on 2022/11/04.
//

import Foundation
import RxSwift
import ReactorKit

final class SearchViewController: UIViewController {

    // MARK: - Variable(s)

    var disposeBag = DisposeBag()

    private var dataSource: UICollectionViewDiffableDataSource<SearchGuideSection, SearchGuideItem>?
    private var snapShot = NSDiffableDataSourceSnapshot<SearchGuideSection, SearchGuideItem>()

    private lazy var searchController: UISearchController = UISearchController(searchResultsController: nil)

    private var searchGuideCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        return collectionView
    }()

    private let contianerView = UIView()
    private let searchResultController = SearchResultContainerViewController()

    init(reactor: SearchReactor) {
        super.init(nibName: nil, bundle: nil)
        self.reactor = reactor
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Override(s)

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.addSubview(self.contianerView)
        self.setupController()
        self.setupSubviews()
        self.setupHierarchy()
        self.setupConstraint()
    }

    private func setupController() {
        self.view.backgroundColor = .mainBackground
        self.navigationItem.hidesSearchBarWhenScrolling = false
    }

    private func setupSubviews() {
        self.setupNavigationBar()
        self.setupSearchController()
        self.setupSearchResultController()
        self.setupSearchGuideCollectionView()
    }

    private func setupHierarchy() {
        self.view.addSubview(self.contianerView)
        self.view.addSubview(self.searchGuideCollectionView)
        self.contianerView.addSubview(self.searchResultController.view)
    }

    private func setupNavigationBar() {
        self.navigationItem.searchController = self.searchController
        self.navigationController?.navigationBar.barStyle = .black
        self.navigationItem.title = "Search"
        self.navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.white]
    }

    private func setupSearchResultController() {
        self.addChild(self.searchResultController)
        self.searchResultController.didMove(toParent: self)
        self.searchResultController.view.isHidden = true
    }

    private func setupSearchController() {
        self.searchController.searchBar.placeholder = "Search GIPHY"
        self.searchController.searchBar.searchBarStyle = .minimal
        self.searchController.searchBar.scopeButtonTitles = GIFType.allCases
            .map { $0.description + "s"}
        self.searchController.hidesNavigationBarDuringPresentation = false
        self.searchController.obscuresBackgroundDuringPresentation = false
        self.searchController.searchBar.setImage(UIImage(), for: .search, state: .normal)
        self.searchController.searchBar.showsScopeBar = true
        self.searchController.automaticallyShowsScopeBar = false
        self.searchController.searchBar.setScopeBarButtonTitleTextAttributes(
            [.font : UIFont.preferredFont(forTextStyle: .headline)],
            for: .normal
        )
    }

    private func setupSearchGuideCollectionView() {
        let layout = createSearchGuideCollectionViewLayout()
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        self.searchGuideCollectionView = collectionView
        self.dataSource = self.createSearchGuideDataSource()
        self.provideSupplementaryViewForCollectionView()
        self.searchGuideCollectionView.register(
            SearchQueryHistoryCollectionViewCell.self,
            forCellWithReuseIdentifier: "history"
        )
        self.searchGuideCollectionView.register(
            TitleHeaderView.self,
            forSupplementaryViewOfKind: "header",
            withReuseIdentifier: "header"
        )
        self.searchGuideCollectionView.isHidden = false
    }

    private func setupConstraint() {
        guard let searchResultView = self.searchResultController.view else {
            return
        }

        self.contianerView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            self.contianerView.topAnchor.constraint(
                equalTo: self.view.topAnchor
            ),
            self.contianerView.bottomAnchor.constraint(
                equalTo: self.view.safeAreaLayoutGuide.bottomAnchor
            ),
            self.contianerView.leadingAnchor.constraint(
                equalTo: self.view.safeAreaLayoutGuide.leadingAnchor
            ),
            self.contianerView.trailingAnchor.constraint(
                equalTo: self.view.safeAreaLayoutGuide.trailingAnchor
            )
        ])

        self.searchResultController.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            searchResultView.topAnchor.constraint(
                equalTo: self.contianerView.topAnchor
            ),
            searchResultView.bottomAnchor.constraint(
                equalTo: self.contianerView.safeAreaLayoutGuide.bottomAnchor
            ),
            searchResultView.leadingAnchor.constraint(
                equalTo: self.contianerView.safeAreaLayoutGuide.leadingAnchor
            ),
            searchResultView.trailingAnchor.constraint(
                equalTo: self.contianerView.safeAreaLayoutGuide.trailingAnchor
            )
        ])

        self.searchGuideCollectionView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            searchGuideCollectionView.topAnchor.constraint(
                equalTo: self.view.safeAreaLayoutGuide.topAnchor
            ),
            searchGuideCollectionView.bottomAnchor.constraint(
                equalTo: self.view.safeAreaLayoutGuide.bottomAnchor
            ),
            searchGuideCollectionView.leadingAnchor.constraint(
                equalTo: self.view.safeAreaLayoutGuide.leadingAnchor
            ),
            searchGuideCollectionView.trailingAnchor.constraint(
                equalTo: self.view.safeAreaLayoutGuide.trailingAnchor
            )
        ])
    }

    private func setSnapshot(items: [SearchGuideItem], for section: SearchGuideSection) {
        let currentQueryItems = self.snapShot.itemIdentifiers(inSection: .searchHistory)
        self.snapShot.deleteItems(currentQueryItems)
        self.snapShot.appendItems(items, toSection: section)
        self.dataSource?.apply(self.snapShot)
    }

    private func createSearchGuideCollectionViewLayout() -> UICollectionViewLayout {
        let configuration = UICollectionViewCompositionalLayoutConfiguration()
        configuration.interSectionSpacing = 10

        let layout = UICollectionViewCompositionalLayout(
            sectionProvider: { _, _ in
                let item = NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(
                    widthDimension: .estimated(100),
                    heightDimension: .fractionalHeight(1.0)
                ))
                item.contentInsets = NSDirectionalEdgeInsets(top: 2, leading: 2, bottom: 2, trailing: 2)

                let groupSize = NSCollectionLayoutSize(
                    widthDimension: .estimated(100),
                    heightDimension: .absolute(50)
                )
                let group = NSCollectionLayoutGroup.horizontal(
                    layoutSize: groupSize,
                    subitems: [item]
                )

                let section = NSCollectionLayoutSection(group: group)
                section.interGroupSpacing = 10
                let titleSize = NSCollectionLayoutSize(
                    widthDimension: .fractionalWidth(1.0),
                    heightDimension: .estimated(30)
                )
                let titleSupplementary = NSCollectionLayoutBoundarySupplementaryItem(
                    layoutSize: titleSize,
                    elementKind: "header",
                    alignment: .top
                )
                section.boundarySupplementaryItems = [titleSupplementary]
                section.orthogonalScrollingBehavior = .continuous
                section.contentInsets = .init(top: 6, leading: 10, bottom: 6, trailing: 10)
                return section
            },
            configuration: configuration
        )

        return layout
    }

    private func provideSupplementaryViewForCollectionView() {
        self.dataSource?.supplementaryViewProvider = { (_, _, indexPath) in
            guard let header = self.searchGuideCollectionView.dequeueReusableSupplementaryView(
                ofKind: "header",
                withReuseIdentifier: "header",
                for: indexPath
            ) as? TitleHeaderView else { return nil }
            header.configure(for: self.snapShot.sectionIdentifiers[indexPath.section].title)
            return header
        }
    }

    private func createSearchGuideDataSource() -> UICollectionViewDiffableDataSource<SearchGuideSection, SearchGuideItem> {
        return UICollectionViewDiffableDataSource<SearchGuideSection, SearchGuideItem>(
            collectionView: self.searchGuideCollectionView
        ) { collectionView, indexPath, itemIdentifier in
            guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: "history",
                for: indexPath
            ) as? SearchQueryHistoryCollectionViewCell else {
                return nil
            }
            switch itemIdentifier {
            case .searchQueryHistory(let query):
                cell.configureContent(query)
                return cell
            }
        }
    }
}

// MARK: - Bind

extension SearchViewController: View {
    func bind(reactor: SearchReactor) {
        self.searchController.searchBar.rx.textDidBeginEditing
            .bind(onNext: { _ in
                self.searchResultController.view.isHidden = true
                self.searchGuideCollectionView.isHidden = false
            })
            .disposed(by: self.disposeBag)

        self.searchController.searchBar.rx.textDidEndEditing
            .bind(onNext: { _ in
                self.searchResultController.view.isHidden = false
                self.searchGuideCollectionView.isHidden = true
            })
            .disposed(by: self.disposeBag)
        self.snapShot.appendSections([.searchHistory])
        self.bindAction(reactor: reactor)
        self.bindState(reactor: reactor)
    }

    private func bindAction(reactor: SearchReactor) {
        self.rx.methodInvoked(#selector(viewDidLoad)).map { _ in }
          .map { Reactor.Action.refresh }
          .bind(to: reactor.action)
          .disposed(by: self.disposeBag)

        self.searchController.searchBar.rx.text
            .orEmpty
            .map { Reactor.Action.updateQuery($0) }
            .bind(to: reactor.action)
            .disposed(by: self.disposeBag)

        self.searchResultController.searchResultCollectionView.rx.didScroll
            .filter {
                let targetOffset = self.searchResultController.searchResultCollectionView.contentOffset.y + self.view.frame.height
                let scrollViewHeight = self.searchResultController.searchResultCollectionView.contentSize.height

                return targetOffset > scrollViewHeight - (self.searchResultController.view.frame.height * 0.4)
            }
            .map { Reactor.Action.loadNextPage }
            .bind(to: reactor.action)
            .disposed(by: self.disposeBag)

        self.searchController.searchBar.rx.searchButtonClicked
            .map { Reactor.Action.searchSessionBegin }
            .bind(to: reactor.action)
            .disposed(by: self.disposeBag)

        self.searchController.searchBar.rx.selectedScopeButtonIndex
            .map { _ in Reactor.Action.searchSessionBegin }
            .bind(to: reactor.action)
            .disposed(by: self.disposeBag)

        self.searchController.searchBar.rx.selectedScopeButtonIndex
            .map { Reactor.Action.updateSearchScope($0) }
            .bind(to: reactor.action)
            .disposed(by: self.disposeBag)

        self.searchResultController.searchResultCollectionView.rx.itemSelected
            .map { Reactor.Action.itemDidSelect($0) }
            .bind(to: reactor.action)
            .disposed(by: self.disposeBag)

        self.searchGuideCollectionView.rx.itemSelected
            .map { Reactor.Action.queryHistoryDidSelect($0) }
            .bind(to: reactor.action)
            .disposed(by: self.disposeBag)
    }

    private func bindState(reactor: SearchReactor) {
        reactor.state
            .observe(on: MainScheduler.instance)
            .map { $0.imagesSearched }
            .subscribe(onNext: { [weak searchResultController] images in
                let searchItems = images.map { SearchItem.image($0) }
                searchResultController?.appendSearchResultSnapshot(items: searchItems, for: .searchResult)
            })
            .disposed(by: self.disposeBag)

        reactor.state
            .map { $0.queryHistory }
            .subscribe(onNext: { [weak self] queries in
                self?.setSnapshot(
                    items: queries.map { SearchGuideItem.searchQueryHistory($0) },
                    for: .searchHistory
                )
            })
            .disposed(by: self.disposeBag)
    }
}

