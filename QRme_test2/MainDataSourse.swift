//
//  MainDataSourse.swift
//  QRme_test2
//
//  Created by Михаил Бобылев on 30.01.2025.
//

import UIKit
import Combine

final class MainDataSourse: UICollectionViewDiffableDataSource<SectionModel, AnyItemModel> {
    init(collectionView: UICollectionView, manager: MainCollectionViewManagerProtocol, pagingInfoSubject: PassthroughSubject<PagingInfo, Never>) {
        super.init(collectionView: collectionView) { collectionView, indexPath, itemModel in
            switch itemModel.type {
            case .single:
                if let singleModel = itemModel.value as? SingleItem.SingleColorItem {
                    guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SingleCollectionCell.reuseID, for: indexPath) as?
                            SingleCollectionCell else { return UICollectionViewCell() }
                    cell.configure(itemModel: singleModel)
                    return cell
                }
            case .carousel:
                if let carouselModel = itemModel.value as? CarouselItem.CarouselColorItem {
                    guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CarouselCollectionCell.reuseID, for: indexPath) as?
                            CarouselCollectionCell else { return UICollectionViewCell() }
                    cell.configure(itemModel: carouselModel)
                    return cell
                }
            case .announcement:
                if let anouncementModel = itemModel.value as? AnouncementItem.AnouncementModel {
                    guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: AnouncementCollectionCell.reuseID, for: indexPath) as?
                            AnouncementCollectionCell else { return UICollectionViewCell() }
                    cell.configure(itemModel: anouncementModel)
                    return cell
                }
            }
            
            return nil
        }
        
        self.supplementaryViewProvider = { collectionView, kind, indexPath in
            //guard let itemType = self.itemIdentifier(for: indexPath) else { return UICollectionReusableView() }
            guard let sectionType = self.sectionIdentifier(for: indexPath.section) else { return UICollectionReusableView() }
            if kind == UICollectionView.elementKindSectionHeader {
                switch sectionType.type {
                case .announcement:
                    return nil
                case .single:
                    guard let header = collectionView.dequeueReusableSupplementaryView(
                        ofKind: kind,
                        withReuseIdentifier: HeaderView.reuseID,
                        for: indexPath
                    ) as? HeaderView else { return UICollectionReusableView() }
                    
                    header.configure(with: sectionType.title)
                    return header
                case .carousel:
                    guard let header = collectionView.dequeueReusableSupplementaryView(
                        ofKind: kind,
                        withReuseIdentifier: HeaderView.reuseID,
                        for: indexPath
                    ) as? HeaderView else { return UICollectionReusableView() }
                    
                    header.configure(with: sectionType.title)
                    return header
                }
            }
            
            if kind == UICollectionView.elementKindSectionFooter {
                switch sectionType.type {
                case .announcement:
                    return nil
                case .single:
                    guard let footer = collectionView.dequeueReusableSupplementaryView(
                        ofKind: kind,
                        withReuseIdentifier: FooterView.reuseID,
                        for: indexPath
                    ) as? FooterView else { return UICollectionReusableView() }
                    
                    footer.delegate = manager as? FooterViewDelegate
                    footer.configure(with: sectionType.likes, description: sectionType.description)
                    return footer
                case .carousel:
                    guard let footer = collectionView.dequeueReusableSupplementaryView(
                        ofKind: kind,
                        withReuseIdentifier: FooterView.reuseID,
                        for: indexPath
                    ) as? FooterView else { return UICollectionReusableView() }
                    
                    footer.delegate = manager as? FooterViewDelegate
                    footer.configure(with: sectionType.likes, description: sectionType.description)
                    return footer
                }
            }
            
            if kind == "PagerKind" {
                switch sectionType.type {
                case .announcement, .single:
                    return nil
                case .carousel:
                    guard let pagerView = collectionView.dequeueReusableSupplementaryView(
                        ofKind: kind,
                        withReuseIdentifier: PagerView.reuseID,
                        for: indexPath
                    ) as? PagerView else { return UICollectionReusableView() }
                    
                    pagerView.configure(numberOfPages: sectionType.countOfItems ?? 0)
                    pagerView.subscribeTo(subject: pagingInfoSubject, for: indexPath.section)
                    return pagerView
                }
            }
            
            return nil
        }
    }
}

//final class MainDataSourse: UICollectionViewDiffableDataSource<SectionModel, AnyItemModel> {
//    
//    private let manager: MainCollectionViewManagerProtocol
//    private let pagingInfoSubject: PassthroughSubject<PagingInfo, Never>
//
//    // UICollectionView
//    private weak var collectionView: UICollectionView?
//
//    // Отложенная инициализация dataSource
//    private lazy var dataSource: UICollectionViewDiffableDataSource<SectionModel, AnyItemModel> = {
//        guard let collectionView = collectionView else {
//            fatalError("CollectionView не был установлен")
//        }
//
//        let dataSource = UICollectionViewDiffableDataSource<SectionModel, AnyItemModel>(collectionView: collectionView) { [weak self] collectionView, indexPath, itemModel in
//            guard let sectionType = self?.sectionIdentifier(for: indexPath.section) else { return nil }
//            switch sectionType.type {
//            case .single:
//                if let singleModel = itemModel.value as? SingleItem.SingleColorItem {
//                    guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SingleCollectionCell.reuseID, for: indexPath) as?
//                            SingleCollectionCell else { return UICollectionViewCell() }
//                    cell.configure(itemModel: singleModel)
//                    return cell
//                }
//            case .carousel:
//                if let carouselModel = itemModel.value as? CarouselItem.CarouselColorItem {
//                    guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CarouselCollectionCell.reuseID, for: indexPath) as?
//                            CarouselCollectionCell else { return UICollectionViewCell() }
//                    cell.configure(itemModel: carouselModel)
//                    return cell
//                }
//            case .announcement:
//                if let announcementModel = itemModel.value as? AnouncementItem.AnouncementModel {
//                    guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: AnouncementCollectionCell.reuseID, for: indexPath) as?
//                            AnouncementCollectionCell else { return UICollectionViewCell() }
//                    cell.configure(itemModel: announcementModel)
//                    return cell
//                }
//            }
//            return nil
//        }
//
//        // Конфигурация заголовков и футеров
//        dataSource.supplementaryViewProvider = { [weak self] collectionView, kind, indexPath in
//            guard let sectionType = self?.sectionIdentifier(for: indexPath.section) else { return UICollectionReusableView() }
//            
//            if kind == UICollectionView.elementKindSectionHeader {
//                switch sectionType.type {
//                case .announcement:
//                    return nil
//                case .single, .carousel:
//                    guard let header = collectionView.dequeueReusableSupplementaryView(
//                        ofKind: kind,
//                        withReuseIdentifier: HeaderView.reuseID,
//                        for: indexPath
//                    ) as? HeaderView else { return UICollectionReusableView() }
//                    header.configure(with: sectionType.title)
//                    return header
//                }
//            }
//            
//            if kind == UICollectionView.elementKindSectionFooter {
//                switch sectionType.type {
//                case .announcement:
//                    return nil
//                case .single, .carousel:
//                    guard let footer = collectionView.dequeueReusableSupplementaryView(
//                        ofKind: kind,
//                        withReuseIdentifier: FooterView.reuseID,
//                        for: indexPath
//                    ) as? FooterView else { return UICollectionReusableView() }
//                    
//                    footer.delegate = self?.manager as? FooterViewDelegate
//                    footer.configure(with: sectionType.likes, description: sectionType.description)
//                    return footer
//                }
//            }
//            
//            if kind == "PagerKind", sectionType.type == .carousel {
//                guard let pagerView = collectionView.dequeueReusableSupplementaryView(
//                    ofKind: kind,
//                    withReuseIdentifier: PagerView.reuseID,
//                    for: indexPath
//                ) as? PagerView else { return UICollectionReusableView() }
//                
//                pagerView.configure(numberOfPages: sectionType.countOfItems ?? 0)
//                pagerView.subscribeTo(subject: self?.pagingInfoSubject ?? PassthroughSubject(), for: indexPath.section)
//                return pagerView
//            }
//            
//            return nil
//        }
//        
//        return dataSource
//    }()
//
//    // Инициализатор класса
//    init(collectionView: UICollectionView, manager: MainCollectionViewManagerProtocol, pagingInfoSubject: PassthroughSubject<PagingInfo, Never>) {
//        self.collectionView = collectionView
//        self.manager = manager
//        self.pagingInfoSubject = pagingInfoSubject
//        
//        super.init(collectionView: collectionView, cellProvider: { _, _, _ in nil }) // Заглушка для инициализации
//
//        self.supplementaryViewProvider = dataSource.supplementaryViewProvider
//    }
//}
