//
//  PCEditViewController.m
//  Photic
//
//  Created by LJP on 2022/8/26.
//

#import "PCEditViewController.h"
#import <TZImagePickerController/TZImagePickerController.h>
#import "PCImageToVideo.h"
#import "GPUImage.h"

@interface PCEditViewController ()<TZImagePickerControllerDelegate>

@property (nonatomic, strong) GPUImageView *mGPUImageView;

@property (nonatomic, strong) AVPlayerItem *mPlayerItem;
@property (nonatomic, strong) AVPlayer *mPlayer;
@property (nonatomic, strong) GPUImageMovie *mGPUMovie;
@property (nonatomic, strong) id playbackTimeObserver;

@end

@implementation PCEditViewController

#pragma mark - Lifecycle
- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor blackColor];
    
    UIBarButtonItem *photosBarButton = [[UIBarButtonItem alloc] initWithTitle:@"添加素材" style:UIBarButtonItemStylePlain target:self action:@selector(showPhotoVC)];
    self.navigationItem.rightBarButtonItems = @[photosBarButton];
    
    [self.view addSubview:self.mGPUImageView];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [UIApplication sharedApplication].idleTimerDisabled = YES;
}

#pragma mark - NSNotification

- (void)playbackFinished:(NSNotification *)notification {
    NSLog(@"视频播放完成通知");
    [self.mPlayerItem seekToTime:kCMTimeZero completionHandler:nil];
    [self.mPlayer play];
}

#pragma mark - Private Method
- (void)playVideo {
    self.mGPUMovie = [[GPUImageMovie alloc] initWithPlayerItem:self.mPlayerItem];
    self.mGPUMovie.playAtActualSpeed = YES;
    self.mGPUMovie.shouldRepeat = YES;
    [self.mGPUMovie addTarget:self.mGPUImageView];
    [self.mGPUMovie startProcessing];

    self.mPlayer = [[AVPlayer alloc] init];
    [self.mPlayer replaceCurrentItemWithPlayerItem:self.mPlayerItem];
    if (self.playbackTimeObserver == nil) {
        [self addPlaybackTimeObserver];
    }
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playbackFinished:) name:AVPlayerItemDidPlayToEndTimeNotification object:self.mPlayer.currentItem];
    [self.mPlayer play];
}

#pragma mark - Public Method

#pragma mark - NSNotification

#pragma mark - Action
- (void)showPhotoVC {
    //每次只选一张
    TZImagePickerController *pickerVC = [[TZImagePickerController alloc] initWithMaxImagesCount:1 delegate:self];
    pickerVC.allowTakePicture = NO;
    pickerVC.allowCameraLocation = NO;
    pickerVC.allowTakeVideo = NO;
    pickerVC.allowPickingVideo = YES;
    [self presentViewController:pickerVC animated:YES completion:nil];
}

#pragma mark - Utility
- (NSString*)getCurrentTime {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"YYYY-MM-dd-HH:mm:ss"];
    NSDate *dateNow = [NSDate date];
    NSString *currentTime = [formatter stringFromDate:dateNow];
    return currentTime;
}

// 添加播放器监听回调
- (void)addPlaybackTimeObserver {
//    __weak typeof(self) weakSelf = self;
    self.playbackTimeObserver = [self.mPlayer addPeriodicTimeObserverForInterval:CMTimeMake(1, 100) queue:NULL usingBlock:^(CMTime time) {
        CGFloat curTime = CMTimeGetSeconds(time);
        NSLog(@"curTime == %lf",curTime);
    }];
}


#pragma mark - TZImagePickerControllerDelegate
- (void)imagePickerController:(TZImagePickerController *)picker didFinishPickingPhotos:(NSArray<UIImage *> *)photos sourceAssets:(NSArray *)assets isSelectOriginalPhoto:(BOOL)isSelectOriginalPhoto {
    //如果是图片，则转成3秒的图片
    UIImage *selectImage = [photos firstObject];
    if (selectImage == nil) {
        NSLog(@"获取不到图片");
        return;
    }

    NSURL *outputURL = [NSURL fileURLWithPath:[NSString stringWithFormat:@"%@/%@.mp4", kDefaultVideoPrefixPath, [self getCurrentTime]]];
    [PCImageToVideo createVideoWithImage:selectImage outputURL:outputURL completeBlock:^(BOOL success) {
        if (success) {
            dispatch_async(dispatch_get_main_queue(), ^{
                self.mPlayerItem = [[AVPlayerItem alloc] initWithURL:outputURL];
                [self playVideo];
            });
        }
    }];
}

- (void)imagePickerController:(TZImagePickerController *)picker didFinishPickingVideo:(UIImage *)coverImage sourceAssets:(PHAsset *)asset {
    //查看视频是否大于3秒

}


#pragma mark - Property
- (GPUImageView *)mGPUImageView {
    if (_mGPUImageView == nil) {
        _mGPUImageView = [[GPUImageView alloc] initWithFrame:self.view.bounds];
        _mGPUImageView.fillMode = kGPUImageFillModePreserveAspectRatio;
        _mGPUImageView.userInteractionEnabled = YES;
    }
    return _mGPUImageView;
}

@end
