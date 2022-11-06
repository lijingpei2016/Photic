//
//  EditorComponentMenuItemBuilder.swift
//  Photic
//
//  Created by lanht on 2022/11/5.
//

import Foundation

class EditItemBuilder {
    static func builderClipItem() -> [EditMenuItem] {
        var items = [EditMenuItem]()
        let menus: [EditMenuOption] = [.cut, .speed, .volum, .animation, .delete, .cutout, .audioSeparate, .edit, .filter, .adjust, .beauty, .mask, .pictureIn, .replace, .shake, .alpha, .voice, .noise, .copy, .backward, .stopMotion]
        for caseItem in menus {
            let imageName = "clip_" + String(describing: caseItem)
            let item = EditMenuItem(option: caseItem, image: imageName)
            items.append(item)
        }
        return items
    }
}
