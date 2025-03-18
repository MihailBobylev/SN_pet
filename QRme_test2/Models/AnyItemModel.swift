//
//  AnyItemModel.swift
//  QRme_test2
//
//  Created by Михаил Бобылев on 18.03.2025.
//

import Foundation

struct AnyItemModel: Hashable {
    private let id = UUID()
    let value: Any // Храним данные любого типа
    let type: SectionType
    
    init<T: Hashable>(_ value: T, type: SectionType, sectionID: UUID) {
        self.value = value
        self.type = type
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    static func == (lhs: AnyItemModel, rhs: AnyItemModel) -> Bool {
        return lhs.id == rhs.id
    }
}
