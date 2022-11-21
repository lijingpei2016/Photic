//
//  PCAssetBuilder.h
//  Photic
//
//  Created by LJP on 2022/11/21.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface PCAssetBuilder : NSObject

+ (AVPlayerItem *)builderAVAssets:(NSArray <AVAsset *> *)arr;

@end

NS_ASSUME_NONNULL_END
