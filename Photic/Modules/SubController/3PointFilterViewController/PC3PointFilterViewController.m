//
//  PC3PointFilterViewController.m
//  Photic
//
//  Created by LJP on 2023/7/19.
//

#import "PC3PointFilterViewController.h"
#import <TZImagePickerController/TZImagePickerController.h>
#import "PCImageToVideo.h"
#import "GPUImage.h"
#import "GPU3x3GridFilter.h"

@interface PC3PointFilterViewController ()

@property (nonatomic, strong) GPUImageView *mGPUImageView;

@property (nonatomic, strong) AVPlayerItem *mPlayerItem;
@property (nonatomic, strong) AVPlayer *mPlayer;
@property (nonatomic, strong) GPUImageMovie *mGPUMovie;
@property (nonatomic, strong) GPU3x3GridFilter *mGridFilter;

@end

@implementation PC3PointFilterViewController

#pragma mark - Lifecycle
- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupUI];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}

#pragma mark - Private Method
- (void)setupUI {
    self.view.backgroundColor = [UIColor blackColor];
    [self.view addSubview:self.mGPUImageView];

    //判断是否有默认图生成的文件
    NSString *pointFilterVideoPath = [NSString stringWithFormat:@"%@/%@.mp4", kDefaultVideoPrefixPath, @"PointFilter"];
    NSURL *outputURL = [NSURL fileURLWithPath:pointFilterVideoPath];

    NSFileManager *fileManager = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:pointFilterVideoPath]) {
        self.mPlayerItem = [[AVPlayerItem alloc] initWithURL:outputURL];
        [self playVideo];
    } else {
        //生成视频
        UIImage *img = [UIImage imageNamed:@"chengyi"];
        [PCImageToVideo createVideoWithImage:img outputURL:outputURL completeBlock:^(BOOL success) {
            if (success) {
                self.mPlayerItem = [[AVPlayerItem alloc] initWithURL:outputURL];
                [self playVideo];
            }
        }];
    }
}

- (void)setupData {
}

#pragma mark - Public Method
- (void)playVideo {
    self.mGPUMovie = [[GPUImageMovie alloc] initWithPlayerItem:self.mPlayerItem];
    self.mGPUMovie.playAtActualSpeed = YES;
    self.mGPUMovie.shouldRepeat = YES;
    
    self.mGridFilter = [[GPU3x3GridFilter alloc] init];
    
    [self.mGPUMovie addTarget:self.mGridFilter];
    [self.mGridFilter addTarget:self.mGPUImageView];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.mGPUMovie startProcessing];
    });

    self.mPlayer = [[AVPlayer alloc] init];
    [self.mPlayer replaceCurrentItemWithPlayerItem:self.mPlayerItem];
    [self.mPlayer play];
}

#pragma mark - NSNotification


#pragma mark - Action

#pragma mark - Delegate

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
