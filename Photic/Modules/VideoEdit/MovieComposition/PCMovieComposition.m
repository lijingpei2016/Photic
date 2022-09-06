//
//  PCMovieComposition.m
//  Photic
//
//  Created by LJP on 2022/9/6.
//

#import "PCMovieComposition.h"
#import <AVFoundation/AVFoundation.h>


@interface PCMovieComposition ()

@property (nonatomic, strong) PCAVCropGroup *avGroup;
@property (nonatomic, strong) NSURL *outputURL;
@property (nonatomic, copy) successCallBack successCallBack;
@property (nonatomic, copy) failCallBack failCallBack;
@property (nonatomic, copy) progressCallBack progressCallBack;


@property (nonatomic, strong) AVMutableComposition *composition;
@property (nonatomic, strong) NSMutableArray *assetArr;
@property (nonatomic, strong) NSArray *videoTrackArr;
@property (nonatomic, strong) NSArray *audioTrackArr;
@property (nonatomic, strong) NSMutableArray *passThroughTimeRanges;
@property (nonatomic, strong) NSMutableArray *transitionTimeRanges;


@end

@implementation PCMovieComposition

- (instancetype)initWithAVGroup:(PCAVCropGroup *)avGroup outputURL:(NSURL *)outputURL
{
    self = [super init];
    if (self) {
        self.avGroup = avGroup;
        self.outputURL = outputURL;
    }
    return self;
}


- (void)composeWithSuccessCallBack:(successCallBack)successCallBack failCallBack:(failCallBack)failCallBack progressCallBack:(progressCallBack)progressCallBack {
    
    self.successCallBack = successCallBack;
    self.failCallBack = failCallBack;
    self.progressCallBack = progressCallBack;

    [self statrCompose];
}

- (void)statrCompose {
    [self initArr];
    [self insertAssetTrackToCompositionTrack];
    [self calculatePassThroughTimeRangesAndTransitionTimeRanges];
    [self mixAudio];
}

- (void)initArr {
    self.assetArr = [[NSMutableArray alloc] init];

    AVMutableComposition *composition = [AVMutableComposition composition];
    self.composition = composition;

    AVMutableCompositionTrack *track1 = [composition addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid];
    AVMutableCompositionTrack *track2 = [composition addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid];
    
    AVMutableCompositionTrack *track3 = [composition addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid];
    AVMutableCompositionTrack *track4 = [composition addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid];

    self.videoTrackArr = @[track1, track2];
    self.audioTrackArr = @[track3, track4];
}

/// 把asset的内容填充入对应的空白轨道
- (void)insertAssetTrackToCompositionTrack {
    
    CMTime cursorTime = kCMTimeZero;
    CMTime transDuration = CMTimeMake(600, 2 * 600);
    
    for (int i = 0; i < self.avGroup.itemArr.count; i++) {
        AVAsset *cursorAsset;
        PCAVCropItem *itemModel = self.avGroup.itemArr[i];
        
        cursorAsset = itemModel.avAsset;
        dispatch_semaphore_t videoTrackSynLoadSemaphore = dispatch_semaphore_create(0);
        dispatch_time_t maxVideoLoadTrackTimeConsume = dispatch_time(DISPATCH_TIME_NOW, 60.0 * NSEC_PER_SEC);
        [cursorAsset loadValuesAsynchronouslyForKeys:[NSArray arrayWithObject:@"tracks"] completionHandler:^{
            dispatch_semaphore_signal(videoTrackSynLoadSemaphore);
        }];
        dispatch_semaphore_wait(videoTrackSynLoadSemaphore, maxVideoLoadTrackTimeConsume);
        
        //记录到数组里  这样子后面就不用重新取了
        [self.assetArr addObject:cursorAsset];
        
        CMTimeRange timeRange = CMTimeRangeMake(itemModel.startTime, itemModel.duration);
        AVAssetTrack *assetTrack = [[cursorAsset tracksWithMediaType:AVMediaTypeVideo] firstObject];
        AVMutableCompositionTrack *compositionTrack = self.videoTrackArr[(i % 2)];

        NSError *error;
        [compositionTrack insertTimeRange:timeRange ofTrack:assetTrack atTime:cursorTime error:&error];
        if (error) {
            NSLog(@"插入原视频轨道失败 == %@", error);
        }
        
        NSError *error1;
        AVAssetTrack *audioTrack = [[cursorAsset tracksWithMediaType:AVMediaTypeAudio] firstObject];
        AVMutableCompositionTrack *audioCompositionTrack = self.audioTrackArr[(i % 2)];
        [audioCompositionTrack insertTimeRange:timeRange ofTrack:audioTrack atTime:cursorTime error:&error1];
        if (error1) {
            NSLog(@"插入原音轨失败,准备插入空白音轨,如果没有提示,则插入空白音轨成功");
            NSString *blandMusicPath = [[NSBundle mainBundle] pathForResource:@"JPVideoEdit_BlandMusic.mp3" ofType:nil];
            NSURL *blandMusicURL = [NSURL fileURLWithPath:blandMusicPath];
            AVAsset *blandSoundAsset = [AVAsset assetWithURL:blandMusicURL];
            AVAssetTrack *blandAssetTrack = [[blandSoundAsset tracksWithMediaType:AVMediaTypeAudio] firstObject];

            NSError *err;
            [audioCompositionTrack insertTimeRange:timeRange ofTrack:blandAssetTrack atTime:cursorTime error:&err];
            if (err) {
                NSLog(@"插入空白音轨失败 ============ %@", err);
            }
        }

        cursorTime = CMTimeAdd(cursorTime, timeRange.duration);
        cursorTime = CMTimeSubtract(cursorTime, transDuration);
    }
}

- (void)calculatePassThroughTimeRangesAndTransitionTimeRanges {
    NSMutableArray *videoAssets = self.assetArr;

    CMTime cursorTime = kCMTimeZero;

    CMTime transDuration = CMTimeMake(600, 2 * 600);

    NSMutableArray *passThroughTimeRanges = [NSMutableArray array];
    NSMutableArray *transitionTimeRanges = [NSMutableArray array];

    NSUInteger videoCount = [videoAssets count];
    
    for (NSUInteger i = 0; i < videoCount; i++) {
        PCAVCropItem *itemModel = self.avGroup.itemArr[i];
        
        CMTimeRange timeRange = CMTimeRangeMake(cursorTime, itemModel.duration);

        if (i > 0) {
            timeRange.start = CMTimeAdd(timeRange.start, transDuration);
            timeRange.duration = CMTimeSubtract(timeRange.duration, transDuration);
        }

        if (i + 1 < videoCount) {
            timeRange.duration = CMTimeSubtract(timeRange.duration, transDuration);
        }

        [passThroughTimeRanges addObject:[NSValue valueWithCMTimeRange:timeRange]];

        cursorTime = CMTimeAdd(cursorTime, itemModel.duration);

        cursorTime = CMTimeSubtract(cursorTime, transDuration);

        if (i + 1 < videoCount) {
            timeRange = CMTimeRangeMake(cursorTime, transDuration);
            NSValue *timeRangeValue = [NSValue valueWithCMTimeRange:timeRange];
            [transitionTimeRanges addObject:timeRangeValue];
        }
    }

    self.passThroughTimeRanges = passThroughTimeRanges;
    self.transitionTimeRanges = transitionTimeRanges;
}

- (void)initVideoComposition {
    AVMutableVideoComposition *videoComposition = [AVMutableVideoComposition videoComposition];

    videoComposition.renderSize = CGSizeMake(720, 1280);
    videoComposition.frameDuration = CMTimeMake(1, 30);

    NSMutableArray *instructionArr = [[NSMutableArray alloc] init];

    for (int i = 0; i < self.assetArr.count; i++) {
        AVMutableCompositionTrack *compositionTrack = self.videoTrackArr[(i % 2)];

        AVMutableVideoCompositionInstruction *passThroughInstruction = [AVMutableVideoCompositionInstruction videoCompositionInstruction];
        
        CMTimeRange passTimeRange = [self.passThroughTimeRanges[i] CMTimeRangeValue];
        passThroughInstruction.timeRange = passTimeRange;

        AVMutableVideoCompositionLayerInstruction *passThroughLayer = [AVMutableVideoCompositionLayerInstruction videoCompositionLayerInstructionWithAssetTrack:compositionTrack];

        //旋转视 频方向
        [self changeVideoDegressWithAVAsset:self.assetArr[i] layerInstruction:passThroughLayer];

        passThroughInstruction.layerInstructions = @[passThroughLayer];

        [instructionArr addObject:passThroughInstruction];

        //转场动画
        if ( (i + 1) < self.assetArr.count) {
            AVMutableVideoCompositionInstruction *transitionInstruction = [AVMutableVideoCompositionInstruction videoCompositionInstruction];
            transitionInstruction.timeRange = [self.transitionTimeRanges[i] CMTimeRangeValue];

            AVMutableVideoCompositionLayerInstruction *fromLayer = [AVMutableVideoCompositionLayerInstruction videoCompositionLayerInstructionWithAssetTrack:compositionTrack];

            AVMutableVideoCompositionLayerInstruction *toLayer = [AVMutableVideoCompositionLayerInstruction videoCompositionLayerInstructionWithAssetTrack:self.videoTrackArr[((1 + i) % 2)]];

            [self addTransitionVideoWithFromLayer:fromLayer toLayer:toLayer fromAVAsset:self.assetArr[i] toAVAsset:self.assetArr[i + 1]  timeRange:[self.transitionTimeRanges[i] CMTimeRangeValue]];

            transitionInstruction.layerInstructions = @[fromLayer, toLayer];

            [instructionArr addObject:transitionInstruction];
        }
    }

    videoComposition.instructions = instructionArr;
}

///混音
- (void)mixAudio {
    AVMutableAudioMix *audioMixTools = [AVMutableAudioMix audioMix];

    NSMutableArray *inputParameterArr = [[NSMutableArray alloc] init];

    for (int i = 0; i < self.transitionTimeRanges.count; i++) {
        AVMutableCompositionTrack *audioTrack1 = self.audioTrackArr[(i % 2)];
        AVMutableCompositionTrack *audioTrack2 = self.audioTrackArr[((i + 1) % 2)];

        AVMutableAudioMixInputParameters *audioParam1 = [AVMutableAudioMixInputParameters audioMixInputParametersWithTrack:audioTrack1];

        AVMutableAudioMixInputParameters *audioParam2 = [AVMutableAudioMixInputParameters audioMixInputParametersWithTrack:audioTrack2];

        CMTimeRange audioTimeRange = [self.transitionTimeRanges[i] CMTimeRangeValue];

        [audioParam1 setVolumeRampFromStartVolume:1 toEndVolume:1 timeRange:audioTimeRange];
        [audioParam1 setTrackID:audioTrack1.trackID];

        [audioParam2 setVolumeRampFromStartVolume:1 toEndVolume:1 timeRange:audioTimeRange];
        [audioParam2 setTrackID:audioTrack2.trackID];

        [inputParameterArr addObject:audioParam1];
        [inputParameterArr addObject:audioParam2];
    }

    audioMixTools.inputParameters = inputParameterArr;

}

- (void)addTransitionVideoWithFromLayer:(AVMutableVideoCompositionLayerInstruction *)fromLayer toLayer:(AVMutableVideoCompositionLayerInstruction *)toLayer fromAVAsset:(AVAsset *)fromAsset toAVAsset:(AVAsset *)toAsset timeRange:(CMTimeRange)timeRange {
    
    if (self.avGroup.transitionsType == PCAVTransitionsTypeNone) {
        return;
    }

    if (self.avGroup.transitionsType == PCAVTransitionsTypeBlur) {
        CGAffineTransform fromTransform = [self getTransformWithAVAsset:fromAsset];
        CGAffineTransform toTransform = [self getTransformWithAVAsset:toAsset];

        [fromLayer setTransformRampFromStartTransform:fromTransform toEndTransform:fromTransform timeRange:timeRange];
        [toLayer setTransformRampFromStartTransform:toTransform toEndTransform:toTransform timeRange:timeRange];

        [fromLayer setOpacityRampFromStartOpacity:1 toEndOpacity:0 timeRange:timeRange];
        [toLayer setOpacityRampFromStartOpacity:0 toEndOpacity:1 timeRange:timeRange];
        return;
    }

    CGAffineTransform fromTransform = [self getTransformWithAVAsset:fromAsset];
    CGAffineTransform toTransform = [self getTransformWithAVAsset:toAsset];

    AVAssetTrack *fromTrack = [[fromAsset tracksWithMediaType:AVMediaTypeVideo] firstObject];
    AVAssetTrack *toTrack = [[toAsset tracksWithMediaType:AVMediaTypeVideo] firstObject];

    NSUInteger fromDegress = [self degressFromVideoFileWithAVAssetTrack:fromTrack];
    NSUInteger toDegress = [self degressFromVideoFileWithAVAssetTrack:toTrack];

    CGSize fromNaturalSize = [self getNaturalSizeWithAVAssetTrack:fromTrack];
    CGSize toNaturalSize = [self getNaturalSizeWithAVAssetTrack:toTrack];

    CGAffineTransform fromDestTransform;
    CGAffineTransform toDestTransform;

    if (self.avGroup.transitionsType == PCAVTransitionsTypeRightToLeft) {
        CGFloat fx = 0;
        CGFloat fy = 0;
        if (fromDegress == 90) {
            fy = fromNaturalSize.width;
        } else if (fromDegress == 270) {
            fy = -fromNaturalSize.width;
        } else if (fromDegress == 180) {
            fx = fromNaturalSize.width;
        } else if (fromDegress == 0) {
            fx = -fromNaturalSize.width;
        }
        fromDestTransform = CGAffineTransformTranslate(fromTransform, fx, fy);

        CGFloat tx = 0;
        CGFloat ty = 0;
        if (toDegress == 90) {
            ty = toNaturalSize.width;
        } else if (toDegress == 270) {
            ty = -toNaturalSize.width;
        } else if (toDegress == 180) {
            tx = toNaturalSize.width;
        } else if (toDegress == 0) {
            tx = -toNaturalSize.width;
        }
        toDestTransform = CGAffineTransformTranslate(toTransform, -tx, -ty);

        [fromLayer setTransformRampFromStartTransform:fromTransform toEndTransform:fromDestTransform timeRange:timeRange];
        [toLayer setTransformRampFromStartTransform:toDestTransform toEndTransform:toTransform timeRange:timeRange];
    } else if (self.avGroup.transitionsType == PCAVTransitionsTypeLeftToRight) {
        CGFloat fx = 0;
        CGFloat fy = 0;
        if (fromDegress == 90) {
            fy = fromNaturalSize.width;
        } else if (fromDegress == 270) {
            fy = -fromNaturalSize.width;
        } else if (fromDegress == 180) {
            fx = fromNaturalSize.width;
        } else if (fromDegress == 0) {
            fx = -fromNaturalSize.width;
        }
        fromDestTransform = CGAffineTransformTranslate(fromTransform, -fx, -fy);

        CGFloat tx = 0;
        CGFloat ty = 0;
        if (toDegress == 90) {
            ty = toNaturalSize.width;
        } else if (toDegress == 270) {
            ty = -toNaturalSize.width;
        } else if (toDegress == 180) {
            tx = toNaturalSize.width;
        } else if (toDegress == 0) {
            tx = -toNaturalSize.width;
        }
        toDestTransform = CGAffineTransformTranslate(toTransform, tx, ty);

        [fromLayer setTransformRampFromStartTransform:fromTransform toEndTransform:fromDestTransform timeRange:timeRange];
        [toLayer setTransformRampFromStartTransform:toDestTransform toEndTransform:toTransform timeRange:timeRange];
    } else if (self.avGroup.transitionsType == PCAVTransitionsTypeBottomToTop) {
        CGFloat fx = 0;
        CGFloat fy = 0;
        if (fromDegress == 90) {
            fx = -fromNaturalSize.width * 1280.0 / 720.0;
        } else if (fromDegress == 270) {
            fx =  fromNaturalSize.width * 1280.0 / 720.0;
        } else if (fromDegress == 180) {
            fy =  fromNaturalSize.width * 1280.0 / 720.0;
        } else if (fromDegress == 0) {
            fy = -fromNaturalSize.width * 1280.0 / 720.0;
        }

        fromDestTransform = CGAffineTransformTranslate(fromTransform, fx, fy);

        CGFloat tx = 0;
        CGFloat ty = 0;
        if (toDegress == 90) {
            tx = toNaturalSize.width * 1280.0 / 720.0;
        } else if (toDegress == 270) {
            tx =  -toNaturalSize.width * 1280.0 / 720.0;
        } else if (toDegress == 180) {
            ty =  -toNaturalSize.width * 1280.0 / 720.0;
        } else if (toDegress == 0) {
            ty = toNaturalSize.width * 1280.0 / 720.0;
        }

        toDestTransform = CGAffineTransformTranslate(toTransform, tx, ty);

        [fromLayer setTransformRampFromStartTransform:fromTransform toEndTransform:fromDestTransform timeRange:timeRange];
        [toLayer setTransformRampFromStartTransform:toDestTransform toEndTransform:toTransform timeRange:timeRange];
    } else if (self.avGroup.transitionsType == PCAVTransitionsTypeTopToBottom) {
        CGFloat fx = 0;
        CGFloat fy = 0;
        if (fromDegress == 90) {
            fx = -fromNaturalSize.width * 1280.0 / 720.0;
        } else if (fromDegress == 270) {
            fx =  fromNaturalSize.width * 1280.0 / 720.0;
        } else if (fromDegress == 180) {
            fy =  fromNaturalSize.width * 1280.0 / 720.0;
        } else if (fromDegress == 0) {
            fy = -fromNaturalSize.width * 1280.0 / 720.0;
        }

        fromDestTransform = CGAffineTransformTranslate(fromTransform, -fx, -fy);

        CGFloat tx = 0;
        CGFloat ty = 0;
        if (toDegress == 90) {
            tx = toNaturalSize.width * 1280.0 / 720.0;
        } else if (toDegress == 270) {
            tx =  -toNaturalSize.width * 1280.0 / 720.0;
        } else if (toDegress == 180) {
            ty =  -toNaturalSize.width * 1280.0 / 720.0;
        } else if (toDegress == 0) {
            ty = toNaturalSize.width * 1280.0 / 720.0;
        }

        toDestTransform = CGAffineTransformTranslate(toTransform, -tx, -ty);

        [fromLayer setTransformRampFromStartTransform:fromTransform toEndTransform:fromDestTransform timeRange:timeRange];
        [toLayer setTransformRampFromStartTransform:toDestTransform toEndTransform:toTransform timeRange:timeRange];
    }
}

///得出显示的size
- (CGSize)getNaturalSizeWithAVAssetTrack:(AVAssetTrack *)assetTrack {
    BOOL isVideoAssetPortrait = [self getVideoAssetIsPortraitWithAVAssetTrack:assetTrack];

    CGSize naturalSize;
    if (isVideoAssetPortrait == YES) {
        naturalSize = CGSizeMake(assetTrack.naturalSize.height, assetTrack.naturalSize.width);
    } else {
        naturalSize = assetTrack.naturalSize;
    }

    return naturalSize;
}

///旋转视频方向
- (void)changeVideoDegressWithAVAsset:(AVAsset *)asset layerInstruction:(AVMutableVideoCompositionLayerInstruction *)layerInstruction {
    
    AVAssetTrack *videoAssetTrack = [[asset tracksWithMediaType:AVMediaTypeVideo] firstObject];
    BOOL isVideoAssetPortrait = [self getVideoAssetIsPortraitWithAVAssetTrack:videoAssetTrack];
    CGSize naturalSize = [self getNaturalSizeWithAVAssetTrack:videoAssetTrack];

    //旋转视频
    float renderWidth, renderHeight;
    renderWidth = 720;
    renderHeight = 1280;

    CGFloat ratio = 0.0;
    CGFloat widthAdd = 0.0;
    CGFloat heightAdd = 0.0;
    ratio = 720.0 / naturalSize.width;
    heightAdd = (1280 - naturalSize.height * ratio) * 0.5;

    // 视频属性
    NSUInteger degress = [self degressFromVideoFileWithAVAssetTrack:videoAssetTrack];
    CGAffineTransform t1;
    CGAffineTransform t2;

    if (degress == 270) {
        t1 = CGAffineTransformMakeTranslation(0, videoAssetTrack.naturalSize.width  * ratio);
        t2 = CGAffineTransformRotate(t1, degreesToRadians(-90));
    } else if (degress == 90) {
        t1 = CGAffineTransformMakeTranslation(videoAssetTrack.naturalSize.height * ratio, 0.0);
        t2 = CGAffineTransformRotate(t1, degreesToRadians(90));
    } else if (degress == 180) {
        t1 = CGAffineTransformMakeTranslation(videoAssetTrack.naturalSize.width  * ratio, videoAssetTrack.naturalSize.height  * ratio);
        t2 = CGAffineTransformRotate(t1, degreesToRadians(180));
    } else {
        t1 = CGAffineTransformMakeTranslation(0.0, 0.0);
        t2 = CGAffineTransformRotate(t1, degreesToRadians(0));
    }

    t2 = CGAffineTransformScale(t2, ratio, ratio);
    if (isVideoAssetPortrait) {
        if (degress == 270) {
            t2 = CGAffineTransformTranslate(t2, -heightAdd / ratio, widthAdd / ratio);
        }else {
            t2 = CGAffineTransformTranslate(t2, heightAdd / ratio, widthAdd / ratio);
        }
    } else {
        if (degress == 180) {
            t2 = CGAffineTransformTranslate(t2, widthAdd / ratio, -heightAdd / ratio);
        } else {
            t2 = CGAffineTransformTranslate(t2, widthAdd / ratio, heightAdd / ratio);
        }
    }

    [layerInstruction setTransform:t2 atTime:kCMTimeZero];
}

///判断是否旋转
- (BOOL)getVideoAssetIsPortraitWithAVAssetTrack:(AVAssetTrack *)assetTrack {
    BOOL isVideoAssetPortrait = NO;
    CGAffineTransform videoTransform = assetTrack.preferredTransform;

    if (videoTransform.a == 0 && videoTransform.b == 1.0 && videoTransform.c == -1.0 && videoTransform.d == 0) {
        isVideoAssetPortrait = YES;
    }
    if (videoTransform.a == 0 && videoTransform.b == -1.0 && videoTransform.c == 1.0 && videoTransform.d == 0) {
        isVideoAssetPortrait = YES;
    }

    return isVideoAssetPortrait;
}

- (CGAffineTransform)getTransformWithAVAsset:(AVAsset *)asset {
    AVAssetTrack *videoAssetTrack = [[asset tracksWithMediaType:AVMediaTypeVideo] firstObject];
    BOOL isVideoAssetPortrait = [self getVideoAssetIsPortraitWithAVAssetTrack:videoAssetTrack];
    CGSize naturalSize = [self getNaturalSizeWithAVAssetTrack:videoAssetTrack];

    //旋转视频
    float renderWidth, renderHeight;
    renderWidth = 720;
    renderHeight = 1280;

    CGFloat ratio = 0.0;
    CGFloat widthAdd = 0.0;
    CGFloat heightAdd = 0.0;
    ratio = 720.0 / naturalSize.width;
    heightAdd = (1280 - naturalSize.height * ratio) * 0.5;

    // 视频属性
    NSUInteger degress = [self degressFromVideoFileWithAVAssetTrack:videoAssetTrack];
    CGAffineTransform t1;
    CGAffineTransform t2;
    if (degress == 270) {
        t1 = CGAffineTransformMakeTranslation(0, videoAssetTrack.naturalSize.width  * ratio);
        t2 = CGAffineTransformRotate(t1, degreesToRadians(-90));
    } else if (degress == 90) {
        t1 = CGAffineTransformMakeTranslation(videoAssetTrack.naturalSize.height * ratio, 0.0);
        t2 = CGAffineTransformRotate(t1, degreesToRadians(90));
    } else if (degress == 180) {
        t1 = CGAffineTransformMakeTranslation(videoAssetTrack.naturalSize.width  * ratio, videoAssetTrack.naturalSize.height  * ratio);
        t2 = CGAffineTransformRotate(t1, degreesToRadians(180));
    } else {
        t1 = CGAffineTransformMakeTranslation(0.0, 0.0);
        t2 = CGAffineTransformRotate(t1, degreesToRadians(0));
    }

    t2 = CGAffineTransformScale(t2, ratio, ratio);
    if (isVideoAssetPortrait) {
//        t2 = CGAffineTransformTranslate(t2, heightAdd / ratio, widthAdd / ratio);
        if (degress == 270) {
            t2 = CGAffineTransformTranslate(t2, -heightAdd / ratio, widthAdd / ratio);
        }else {
            t2 = CGAffineTransformTranslate(t2, heightAdd / ratio, widthAdd / ratio);
        }
    } else {
        if (degress == 180) {
            t2 = CGAffineTransformTranslate(t2, widthAdd / ratio, -heightAdd / ratio);
        } else {
            t2 = CGAffineTransformTranslate(t2, widthAdd / ratio, heightAdd / ratio);
        }
    }

    return t2;
}

- (NSUInteger)degressFromVideoFileWithAVAssetTrack:(AVAssetTrack *)videoTrack {
    NSUInteger degress = 0;

    CGAffineTransform t = videoTrack.preferredTransform;
    if (t.a == 0 && t.b == 1.0 && t.c == -1.0 && t.d == 0) {
        degress = 90;
    } else if (t.a == 0 && t.b == -1.0 && t.c == 1.0 && t.d == 0) {
        degress = 270;
    } else if (t.a == 1.0 && t.b == 0 && t.c == 0 && t.d == 1.0) {
        degress = 0;
    } else if (t.a == -1.0 && t.b == 0 && t.c == 0 && t.d == -1.0) {
        degress = 180;
    }

    return degress;
}


@end
