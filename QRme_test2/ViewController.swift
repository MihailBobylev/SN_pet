//
//  ViewController.swift
//  QRme_test2
//
//  Created by Михаил Бобылев on 30.01.2025.
//

import UIKit
import SnapKit

final class ViewController: UIViewController {
    private lazy var mainCollectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
        collectionView.register(SingleCollectionCell.self, forCellWithReuseIdentifier: SingleCollectionCell.reuseID)
        collectionView.register(CarouselCollectionCell.self, forCellWithReuseIdentifier: CarouselCollectionCell.reuseID)
        collectionView.register(AnouncementCollectionCell.self, forCellWithReuseIdentifier: AnouncementCollectionCell.reuseID)
        collectionView.register(HeaderView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: HeaderView.reuseID)
        collectionView.register(FooterView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: FooterView.reuseID)
        collectionView.register(PagerView.self, forSupplementaryViewOfKind: "PagerKind", withReuseIdentifier: PagerView.reuseID)
        collectionView.backgroundColor = .white
        return collectionView
    }()
    
    private var notificationsCollectionViewManager: MainCollectionViewManagerProtocol?
    
    private let itemsInfo: [CollectionItem] = [
        .carousel(.init(title: "t1", likes: 1, description: "desc1", models: [.init(color: .red) ,.init(color: .blue), .init(color: .green)])),
        .carousel(.init(title: "t1", likes: 1, description: "desc1", models: [.init(color: .red) ,.init(color: .blue), .init(color: .green)])),
        .announcement(.init(models: [.init(text: "Анонс1", color: .cyan),
                                     .init(text: "Анонс2", color: .yellow),
                                     .init(text: "Анонс3", color: .magenta),
                                     .init(text: "Анонс11", color: .cyan),
                                     .init(text: "Анонс22", color: .yellow),
                                     .init(text: "Анонс33", color: .magenta)])),
        .single(.init(title: "t2", likes: 2, description: "desc2", model: .init(color: .cyan))),
        .announcement(.init(models: [.init(text: "Анонс4", color: .brown),
                                     .init(text: "Анонс5", color: .red),
                                     .init(text: "Анонс6", color: .purple),
                                     .init(text: "Анонс44", color: .brown),
                                     .init(text: "Анонс55", color: .red),
                                     .init(text: "Анонс66", color: .purple)])),
        .carousel(.init(title: "t3", likes: 11, description: "desc11", models: [.init(color: .green) ,.init(color: .red), .init(color: .blue)])),
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        
        notificationsCollectionViewManager = MainCollectionViewManager(collectionView: mainCollectionView)
        guard let notificationsCollectionViewManager else { return }
        let layout = notificationsCollectionViewManager.createLayout()
        mainCollectionView.setCollectionViewLayout(layout, animated: false)
        mainCollectionView.delegate = notificationsCollectionViewManager
        
        notificationsCollectionViewManager.fillData(data: itemsInfo)
    }
}

private extension ViewController {
    func setupUI() {
        view.addSubview(mainCollectionView)
        
        mainCollectionView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
}
