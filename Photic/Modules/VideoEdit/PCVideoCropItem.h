//
//  PCEditItem.h
//  Photic
//
//  Created by LJP on 2022/8/26.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>


NS_ASSUME_NONNULL_BEGIN

@interface PCVideoCropItem : NSObject

@property (nonatomic, strong) AVAsset *avAsset;

@property (nonatomic, copy) NSString *videoPath;

@property (nonatomic, assign) CMTime startTime;

@property (nonatomic, assign) CMTime duration;

@end

NS_ASSUME_NONNULL_END
