//
//  PCAVBaseMode.h
//  Photic
//
//  Created by LJP on 2022/9/6.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

typedef enum {
    PCAVCropItemTypeVideo = 0,
    PCAVCropItemTypeAudio = 1,
} PCAVCropItemType;


NS_ASSUME_NONNULL_BEGIN

@interface PCAVCropItem : NSObject

@property (nonatomic, assign) PCAVCropItemType type;

@property (nonatomic, strong) AVAsset *avAsset;

@property (nonatomic, strong) UIImage *coverImage;

@property (nonatomic, assign) CMTime duration;

@property (nonatomic, assign) CMTime startTime;

//@property (nonatomic, assign) CMTimeRange timeRange;

@end

NS_ASSUME_NONNULL_END
