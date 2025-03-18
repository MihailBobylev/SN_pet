//
//  MainItemInfo.swift
//  QRme_test2
//
//  Created by Михаил Бобылев on 30.01.2025.
//

import UIKit

enum SectionType: Hashable {
    case single
    case carousel
    case announcement
}

struct SectionModel: Hashable {
    let id: UUID = UUID()
    let type: SectionType
    let title: String?
    let likes: Int?
    let description: String?
    let countOfItems: Int?
}

enum CollectionItem: Hashable {
    case single(SingleItem)
    case carousel(CarouselItem)
    case announcement(AnouncementItem)
}

struct SingleItem: Hashable {
    let id = UUID()
    let title: String
    let likes: Int
    let description: String
    let model: SingleColorItem
    
    struct SingleColorItem: Hashable {
        let color: UIColor
    }
}

struct CarouselItem: Hashable {
    let id = UUID()
    let title: String
    let likes: Int
    let description: String
    let models: [CarouselColorItem]
    
    struct CarouselColorItem: Hashable {
        let color: UIColor
    }
}

struct AnouncementItem: Hashable {
    let id = UUID()
    let models: [AnouncementModel]
    
    struct AnouncementModel: Hashable {
        let text: String
        let color: UIColor
    }
}
