//
//  PCAssetBuilder.m
//  Photic
//
//  Created by LJP on 2022/11/21.
//

#import "PCAssetBuilder.h"

@implementation PCAssetBuilder

+ (AVPlayerItem *)builderAVAssets:(NSArray <AVAsset *> *)arr {
        
    AVMutableComposition *composition = [AVMutableComposition composition];
    
    AVMutableCompositionTrack *compositionVideoTrack = [composition addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid];
    AVMutableCompositionTrack *compositionAudioTrack = [composition addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid];
    
    CMTime totalDuration = kCMTimeZero;
    for (AVAsset *temp in arr) {
        
        AVAssetTrack *assetTrackVideo = [temp tracksWithMediaType:AVMediaTypeVideo].firstObject;
        AVAssetTrack *assetTrackAudio = [temp tracksWithMediaType:AVMediaTypeAudio].firstObject;
        
        NSError *error;
        [compositionVideoTrack insertTimeRange:assetTrackVideo.timeRange ofTrack:assetTrackVideo atTime:totalDuration error:&error];
        if (error) {
            NSLog(@"插入原视频轨道失败 == %@", error);
        }
        [compositionAudioTrack insertTimeRange:assetTrackAudio.timeRange ofTrack:assetTrackAudio atTime:totalDuration error:&error];
        if (error) {
            NSLog(@"插入原音频轨道失败 == %@", error);
        }
        totalDuration = CMTimeAdd(totalDuration, temp.duration);
    }
        
    
    AVPlayerItem *layerItem = [[AVPlayerItem alloc]initWithAsset:composition];
        
    return layerItem;
}

@end
