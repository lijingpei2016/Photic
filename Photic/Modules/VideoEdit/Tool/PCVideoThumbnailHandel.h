//
//  PCVideoThumbnailHandel.h
//  Photic
//
//  Created by LJP on 2022/9/6.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface PCVideoThumbnailHandel : NSObject

/**
 返回视频帧 -- 同步

 @param asset AVAsset
 @param timeRange 需要操作的时间段
 @param imaegeCount 需要生成的图片数量
 @param imageSize 图片大小
 @return 图片数组
 */
+ (NSMutableArray *)getImageArrayWithAVURLAsset:(AVAsset *)asset timeRange:(CMTimeRange)timeRange imaegeCount:(NSInteger)imaegeCount imageSize:(CGSize)imageSize;


/**
 返回视频帧 -- 异步

 @param asset AVAsset
 @param timeRange 需要操作的时间段
 @param imaegeCount 需要生成的图片数量
 @param imageSize 图片大小
 @param handler (CMTime requestedTime, CGImageRef _Nullable image, CMTime actualTime, AVAssetImageGeneratorResult result, NSError *_Nullable error)
 */
+ (void)getImageArrayWithAVURLAsset:(AVAsset *)asset timeRange:(CMTimeRange)timeRange imaegeCount:(NSInteger)imaegeCount imageSize:(CGSize)imageSize completionHandler:(AVAssetImageGeneratorCompletionHandler)handler;

@end

NS_ASSUME_NONNULL_END
