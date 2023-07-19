//
//  PCVideoThumbnailHandel.m
//  Photic
//
//  Created by LJP on 2022/9/6.
//

#import "PCVideoThumbnailHandel.h"
#import <UIKit/UIKit.h>

@implementation PCVideoThumbnailHandel

+ (void)load {
    
//    @autoreleasepool {
        NSMutableArray *arr = [NSMutableArray array];
        [arr addObject:@"a"];
//    }
    
}

+ (NSMutableArray *)getImageArrayWithAVURLAsset:(AVAsset *)asset timeRange:(CMTimeRange)timeRange imaegeCount:(NSInteger)imaegeCount imageSize:(CGSize)imageSize {
    
    dispatch_semaphore_t videoTrackSynLoadSemaphore = dispatch_semaphore_create(0);
    dispatch_time_t maxVideoLoadTrackTimeConsume = dispatch_time(DISPATCH_TIME_NOW, 60.0 * NSEC_PER_SEC);
    //加载尚未加载的指定键的值
    [asset loadValuesAsynchronouslyForKeys:[NSArray arrayWithObject:@"tracks"] completionHandler:^{
        dispatch_semaphore_signal(videoTrackSynLoadSemaphore);
    }];
    dispatch_semaphore_wait(videoTrackSynLoadSemaphore, maxVideoLoadTrackTimeConsume);

    __block NSMutableArray *imageArr = [[NSMutableArray alloc] init];
    NSMutableArray *timeArr = [[NSMutableArray alloc] init];

    //光标时间
    CMTime cursorTime = timeRange.start;
    //间隔时间
    CMTime intervals = kCMTimeZero;
    CGFloat d = (asset.duration.value * 1.0 / asset.duration.timescale) / (imaegeCount - 1);
    int intd = d * 100;
    float fd = intd / 100.0;
    intervals = CMTimeMakeWithSeconds(fd, 1000);

    CMTime endTime = CMTimeAdd(timeRange.start, timeRange.duration);

    while (CMTIME_COMPARE_INLINE(cursorTime, <=, endTime)) {
        [timeArr addObject:[NSValue valueWithCMTime:cursorTime]];
        cursorTime = CMTimeAdd(cursorTime, intervals);
    }
    // 第一帧取第0.1s 规避有些视频并不是从第0s开始的
    timeArr[0] = [NSValue valueWithCMTime:CMTimeMake(1, 10)];

    AVAssetImageGenerator *imageGenerator = [[AVAssetImageGenerator alloc] initWithAsset:asset];
    imageGenerator.appliesPreferredTrackTransform = YES;
    imageGenerator.requestedTimeToleranceBefore = CMTimeMake(600, 2 *600);
    imageGenerator.requestedTimeToleranceAfter = CMTimeMake(600, 2 *600);
    imageGenerator.maximumSize = imageSize;

    //创建信号量
    dispatch_semaphore_t sem = dispatch_semaphore_create(0);

    __block int errorCount = 0;

    [imageGenerator generateCGImagesAsynchronouslyForTimes:timeArr completionHandler:^(CMTime requestedTime, CGImageRef _Nullable image, CMTime actualTime, AVAssetImageGeneratorResult result, NSError *_Nullable error) {
        if (error) {
            errorCount++;
            NSLog(@"生成缩略图失败 次数%d", errorCount);
        } else {
            UIImage *img = [[UIImage alloc] initWithCGImage:image];
            [imageArr addObject:img];
        }

        if ( (imageArr.count + errorCount) == imaegeCount) {
            //发送信号量
            dispatch_semaphore_signal(sem);
        }
    }];

    //等待信号量
    dispatch_semaphore_wait(sem, DISPATCH_TIME_FOREVER);

    return imageArr;
}

+ (void)getImageArrayWithAVURLAsset:(AVAsset *)asset timeRange:(CMTimeRange)timeRange imaegeCount:(NSInteger)imaegeCount imageSize:(CGSize)imageSize completionHandler:(AVAssetImageGeneratorCompletionHandler)handler {
    dispatch_semaphore_t videoTrackSynLoadSemaphore = dispatch_semaphore_create(0);
    dispatch_time_t maxVideoLoadTrackTimeConsume = dispatch_time(DISPATCH_TIME_NOW, 60.0 * NSEC_PER_SEC);
    //加载尚未加载的指定键的值
    [asset loadValuesAsynchronouslyForKeys:[NSArray arrayWithObject:@"tracks"] completionHandler:^{
        dispatch_semaphore_signal(videoTrackSynLoadSemaphore);
    }];
    dispatch_semaphore_wait(videoTrackSynLoadSemaphore, maxVideoLoadTrackTimeConsume);

    NSMutableArray *timeArr = [[NSMutableArray alloc] init];

    //光标时间
    CMTime cursorTime = timeRange.start;
    //间隔时间
    CMTime intervals = kCMTimeZero;
    CGFloat d = (asset.duration.value * 1.0 / asset.duration.timescale) / (imaegeCount);
    int intd = d * 100;
    float fd = intd / 100.0;
    intervals = CMTimeMakeWithSeconds(fd, 1000);

    CMTime endTime = CMTimeAdd(timeRange.start, timeRange.duration);

    while (CMTIME_COMPARE_INLINE(cursorTime, <=, endTime)) {
        if (timeArr.count < imaegeCount) {
            [timeArr addObject:[NSValue valueWithCMTime:cursorTime]];
        }
        cursorTime = CMTimeAdd(cursorTime, intervals);
    }
    // 第一帧取第0.1s 规避有些视频并不是从第0s开始的
    timeArr[0] = [NSValue valueWithCMTime:CMTimeMake(1, 10)];

    AVAssetImageGenerator *imageGenerator = [[AVAssetImageGenerator alloc] initWithAsset:asset];
    imageGenerator.appliesPreferredTrackTransform = YES;
    imageGenerator.requestedTimeToleranceBefore = CMTimeMake(600, 2*600);
    imageGenerator.requestedTimeToleranceAfter = CMTimeMake(600, 2*600);
    imageGenerator.maximumSize = imageSize;

    [imageGenerator generateCGImagesAsynchronouslyForTimes:timeArr completionHandler:^(CMTime requestedTime, CGImageRef _Nullable image, CMTime actualTime, AVAssetImageGeneratorResult result, NSError *_Nullable error) {
        if (handler) {
            handler(requestedTime, image, actualTime, result, error);
        }
    }];
}

@end
