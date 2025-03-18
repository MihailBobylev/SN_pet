//
//  MainCollectionViewManager.swift
//  QRme_test2
//
//  Created by Михаил Бобылев on 30.01.2025.
//

import UIKit
import Combine

protocol MainCollectionViewManagerProtocol: UICollectionViewDelegate {
    var pagingInfoSubject: PassthroughSubject<PagingInfo, Never> { get }
    func createLayout() -> UICollectionViewCompositionalLayout
    func fillData(data: [CollectionItem])
}

final class MainCollectionViewManager: NSObject, MainCollectionViewManagerProtocol {
    var pagingInfoSubject = PassthroughSubject<PagingInfo, Never>()
    private var data: [CollectionItem] = []
    private var collectionView: UICollectionView
    private lazy var dataSource: MainDataSourse = {
        return MainDataSourse(collectionView: collectionView, manager: self, pagingInfoSubject: pagingInfoSubject)
    }()
    
    init(collectionView: UICollectionView) {
        self.collectionView = collectionView
        super.init()
    }
    
    func createLayout() -> UICollectionViewCompositionalLayout {
        let layout = UICollectionViewCompositionalLayout { [weak self] sectionIndex, layoutEnvironment in
            guard let self else { return nil }
            let sectionType = data[sectionIndex]
            
            // Хедер
            let headerItem = makeHeader()
            
            //Футер
            let footerItem = makeFooter()
            
            //Элементы
            let group = makeItemsGroup(for: sectionType)
            
            //Секция
            let section = NSCollectionLayoutSection(group: group)
            
            switch sectionType {
            case .single:
                section.boundarySupplementaryItems = [headerItem, footerItem]
            case .carousel:
                //Пейджер
                let pagerItem = makePagerItem()
                
                section.boundarySupplementaryItems = [headerItem, footerItem, pagerItem]
                section.orthogonalScrollingBehavior = .paging
                section.visibleItemsInvalidationHandler = { [weak self] (items, offset, env) -> Void in
                    guard let self else { return }
                    let pageWidth = env.container.contentSize.width
                    let currentPage = Int((offset.x / pageWidth).rounded())
                    pagingInfoSubject.send(PagingInfo(sectionIndex: sectionIndex, currentPage: currentPage))
                }
            case .announcement:
                section.orthogonalScrollingBehavior = .continuous
                section.interGroupSpacing = 8.dhs
                section.contentInsets = .init(top: 0, leading: 20.dhs, bottom: 0, trailing: 20.dhs)
            }
            
            return section
        }
        let config = UICollectionViewCompositionalLayoutConfiguration()
        config.interSectionSpacing = 20.dvs
        layout.configuration = config
        
        return layout
    }
    
    func fillData(data: [CollectionItem]) {
        self.data = data
        applySnapshot(for: dataSource)
    }
}

extension MainCollectionViewManager: FooterViewDelegate {
    func collapseDescription() {
        print("collapseDescription")
        UIView.animate(withDuration: 0.3, animations: {
            self.collectionView.performBatchUpdates(nil)
        })
    }
}

private extension MainCollectionViewManager {
    func makeHeader() -> NSCollectionLayoutBoundarySupplementaryItem {
        let headerSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .absolute(44.dvs)
        )
        let headerItem = NSCollectionLayoutBoundarySupplementaryItem(
            layoutSize: headerSize,
            elementKind: UICollectionView.elementKindSectionHeader,
            alignment: .top
        )
        
        return headerItem
    }
    
    func makeFooter() -> NSCollectionLayoutBoundarySupplementaryItem {
        let footerSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .estimated(80.dvs)
        )
        let footerItem = NSCollectionLayoutBoundarySupplementaryItem(
            layoutSize: footerSize,
            elementKind: UICollectionView.elementKindSectionFooter,
            alignment: .bottom
        )
        footerItem.edgeSpacing = NSCollectionLayoutEdgeSpacing(
            leading: nil,
            top: nil,
            trailing: nil,
            bottom: .fixed(20.dvs)
        )
        
        return footerItem
    }
    
    func makeItemsGroup(for section: CollectionItem) -> NSCollectionLayoutGroup {
        switch section {
        case .single, .carousel:
            let item = NSCollectionLayoutItem(
                layoutSize: NSCollectionLayoutSize(
                    widthDimension: .fractionalWidth(1.0),
                    heightDimension: .absolute(400.dvs)
                )
            )
            
            let group = NSCollectionLayoutGroup.horizontal(
                layoutSize: NSCollectionLayoutSize(
                    widthDimension: .fractionalWidth(1.0),
                    heightDimension: .absolute(400.dvs)
                ),
                subitems: [item]
            )
            return group
        case .announcement:
            let item = NSCollectionLayoutItem(
                layoutSize: NSCollectionLayoutSize(
                    widthDimension: .absolute(200.dhs),
                    heightDimension: .absolute(120.dvs)
                )
            )
            
            let group = NSCollectionLayoutGroup.horizontal(
                layoutSize: NSCollectionLayoutSize(
                    widthDimension: .absolute(200.dhs),
                    heightDimension: .absolute(120.dvs)
                ),
                subitems: [item]
            )
            
            return group
        }
    }
    
    func makePagerItem() -> NSCollectionLayoutBoundarySupplementaryItem {
        let anchor = NSCollectionLayoutAnchor(
            edges: [.bottom],
            absoluteOffset: CGPoint(x: 0, y: -30.dvs)
        )
        
        let size = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                          heightDimension: .absolute(50))
        
        let pagerItem = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: size,
                                                                    elementKind: "PagerKind",
                                                                    containerAnchor: anchor)
        
        pagerItem.zIndex = 999
        
        return pagerItem
    }
    
    func applySnapshot(for dataSource: MainDataSourse) {
        var snapshot = NSDiffableDataSourceSnapshot<SectionModel, AnyItemModel>()
        
        // Заполняем секции элементами
        for item in data {
            var itemsToAdd: [AnyItemModel] = []
            var section: SectionModel?
            
            switch item {
            case .single(let item):
                section = .init(type: .single, title: item.title, likes: item.likes, description: item.description, countOfItems: nil)
                if let section {
                    itemsToAdd = [AnyItemModel(item.model, type: .single, sectionID: section.id)]
                }
            case .carousel(let item):
                section = .init(type: .carousel, title: item.title, likes: item.likes, description: item.description, countOfItems: item.models.count)
                if let section {
                    itemsToAdd = item.models.map { AnyItemModel($0, type: .carousel, sectionID: section.id) }
                }
            case .announcement(let item):
                section = .init(type: .announcement, title: nil, likes: nil, description: nil, countOfItems: nil)
                if let section {
                    itemsToAdd = item.models.map { AnyItemModel($0, type: .announcement, sectionID: section.id) }
                }
            }
            
            if let section {
                snapshot.appendSections([section])
                snapshot.appendItems(itemsToAdd, toSection: section)
            }
        }
        
        DispatchQueue.main.async {
            dataSource.apply(snapshot, animatingDifferences: true)
        }
    }
}
