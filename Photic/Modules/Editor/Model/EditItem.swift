//
//  EditItem.swift
//  Photic
//
//  Created by lanht on 2022/10/31.
//

import UIKit

enum EditOption {
    case clip
    case music
    case text
    case stickers
    case pictureIn
    case specialEffect
    case filter
}

struct EditItem {
    let option: EditOption
    let name: String
    let image: String
}
