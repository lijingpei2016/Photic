//
//  PCAVCropGroup.h
//  Photic
//
//  Created by LJP on 2022/9/6.
//

#import <Foundation/Foundation.h>
#import "PCAVCropItem.h"

typedef NS_ENUM (NSInteger, PCAVTransitionsType) {
    PCAVTransitionsTypeNone        = 0,       // 无效果
    PCAVTransitionsTypeRightToLeft = 1,       // 左划
    PCAVTransitionsTypeLeftToRight = 2,       // 右划
    PCAVTransitionsTypeBottomToTop = 3,       // 上划
    PCAVTransitionsTypeTopToBottom = 4,       // 下划
    PCAVTransitionsTypeBlur        = 5,       //渐入渐出
};

NS_ASSUME_NONNULL_BEGIN

@interface PCAVCropGroup : NSObject

@property (nonatomic, strong) NSMutableArray <PCAVCropItem *> *itemArr;

///转场动画类型 (暂时先一个)
@property (nonatomic, assign) PCAVTransitionsType transitionsType;


@end

NS_ASSUME_NONNULL_END
