//
//  EditItem.swift
//  Photic
//
//  Created by lanht on 2022/10/31.
//

import UIKit

enum EditOption: String {
    
    case clip = "剪辑"
    case music = "音频"
    case text = "文本"
    case stickers = "贴纸"
    case pictureIn = "画中画"
    case specialEffect = "特效"
    case filter = "滤镜"
}

enum EditMenuOption: String {
    //----------- Clip ------------
    ///分割
    case cut = "分割"
    ///变速
    case speed = "变速"
    ///音量
    case volum = "音量"
    ///动画
    case animation = "动画"
    ///删除
    case delete = "删除"
    ///抠像
    case cutout = "抠像"
    ///音频分离
    case audioSeparate = "音频分离"
    ///编辑
    case edit = "编辑"
    ///滤镜
    case filter = "滤镜"
    ///调节
    case adjust = "调节"
    ///美颜
    case beauty = "美颜"
    ///蒙版
    case mask = "蒙版"
    ///切画中画
    case pictureIn = "切画中画"
    ///替换
    case replace = "替换"
    ///防抖
    case shake = "防抖"
    ///不透明度
    case alpha = "不透明度"
    ///变声
    case voice = "变声"
    ///降噪
    case noise = "降噪"
    ///复制
    case copy = "复制"
    ///倒放
    case backward = "倒放"
    ///定格
    case stopMotion = "定格"
}

struct EditItem {
    let option: EditOption
    let image: String
}

struct EditMenuItem {
    let option: EditMenuOption
    let image: String
}
