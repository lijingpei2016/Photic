//
//  PHCameraViewController.m
//  Photic
//
//  Created by LJP on 2022/8/22.
//

#import "PHOCameraViewController.h"
#import "GPUImageBeautifyFilter.h"
#import <MBProgressHUD/MBProgressHUD.h>

@interface PHOCameraViewController ()

@property (nonatomic, strong) GPUImageStillCamera *mCamera;
@property (nonatomic, strong) GPUImageView *mGPUImageView;

@property (nonatomic, strong) GPUImageBeautifyFilter *mBeautyFilter;
@property (nonatomic, strong) GPUImageBrightnessFilter *mBrightFilter;
@property (nonatomic, strong) GPUImageLookupFilter *mLookupFilter;
@property (nonatomic, strong) GPUImagePicture *mLookupImageSource;

@property (nonatomic, strong) GPUImageMovieWriter *mMovieWriter;
@property (nonatomic, strong) NSURL *mOutputURL;

/// 镜头缩放系数
@property (nonatomic, assign) CGFloat cameraZoom;

///焦点框
@property (nonatomic, strong) UIView *focusView;

/// 拍照
@property (nonatomic, strong) UIButton *pictureBtn;

/// 拍视频
@property (nonatomic, strong) UIButton *videoBtn;

@end

@implementation PHOCameraViewController

#pragma mark - Lifecycle
- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupUI];
    [self setupCamera];
}


#pragma mark - Action
///改变颜色滤镜效果
- (void)changeLookupFilter {

}

///左右滑动手势
- (void)handleSwipeFrom:(UISwipeGestureRecognizer *)recognizer {

}

///单击手势
- (void)clickOnGPUImageView:(UIGestureRecognizer *)recognizer {
    //聚焦点
    CGPoint point = [recognizer locationInView:self.mGPUImageView];

    [self runBoxAnimationOnView:self.focusView point:point];

    [self.mCamera tappedToFocusAtPoint:[self captureDevicePointForPoint:point]];
    [self.mCamera setExposurePoint:[self captureDevicePointForPoint:point]];
}

///聚焦框动画
- (void)runBoxAnimationOnView:(UIView *)view point:(CGPoint)point {
    view.center = point;

    view.hidden = NO;

    [UIView animateWithDuration:0.2 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        view.layer.transform = CATransform3DMakeScale(0.5, 0.5, 1.0);
    } completion:^(BOOL complete) {
        double delayInSeconds = 0.5;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void) {
           view.hidden = YES;
           view.transform = CGAffineTransformIdentity;
        });
    }];
}

///双击手势
- (void)clickGPUImageViewDoubleTap {
    [self.mCamera rotateCamera];
}

///捏合手势
- (void)clickGPUImageViewPinchTap:(UIPinchGestureRecognizer *)recognizer {
    CGFloat changeScale = recognizer.scale;

    self.cameraZoom = self.cameraZoom * changeScale;

    self.cameraZoom = MAX(self.cameraZoom, 1.0);
    self.cameraZoom = MIN(self.cameraZoom, 10.0);

    [self.mCamera setCameraZoomFactor:self.cameraZoom];

    recognizer.scale = 1.0;
}

- (void)clickPictureBtn {
    NSLog(@"拍照");
    [self.mCamera capturePhotoAsImageProcessedUpToFilter:self.mBrightFilter withCompletionHandler:^(UIImage *processedImage, NSError *error) {
        if (error) {
            NSLog(@"拍照失败");
            return;
        }
        UIImageWriteToSavedPhotosAlbum(processedImage, nil, nil, nil);
    }];
}

- (void)clickVideoBtn {
    
    self.videoBtn.selected = !self.videoBtn.selected;
    
    if(self.videoBtn.isSelected) {
        NSLog(@"开始录制");
        unlink([self.mOutputURL.path UTF8String]);
        [self.mCamera isSmoothAutoFocusEnabledWith:YES];
        [self.mBrightFilter addTarget:self.mMovieWriter];
        [self.mMovieWriter startRecording];
    }else {
        NSLog(@"结束录制");
        
        __weak typeof(self) weakSelf = self;
        [self.mMovieWriter finishRecordingWithCompletionHandler:^{
            [weakSelf.mCamera isSmoothAutoFocusEnabledWith:NO];

            [weakSelf.mBrightFilter removeTarget:weakSelf.mMovieWriter];

            [weakSelf setupMovieWriter];
            
            UISaveVideoAtPathToSavedPhotosAlbum(self.mOutputURL.path, nil, nil, nil);
        }];
    }
}

#pragma mark - Utility
///计算点的位置
- (CGPoint)captureDevicePointForPoint:(CGPoint)point {
    CGPoint point1;
    point1 = CGPointMake(point.x / kSCREEN_WIDTH, point.y / kSCREEN_HEIGHT);
    return point1;
}

#pragma mark - Private Method
- (void)setupUI {
    [self.view addSubview:self.mGPUImageView];
    [self.view addSubview:self.videoBtn];
    [self.view addSubview:self.pictureBtn];
    [self.view addSubview:self.focusView];
}

- (void)setupCamera {

    self.mBeautyFilter = [[GPUImageBeautifyFilter alloc]init];
    self.mBrightFilter = [[GPUImageBrightnessFilter alloc]init];
    self.mBrightFilter.brightness = 0.01;
    
    [self.mCamera addTarget:self.mBeautyFilter];
    [self.mBeautyFilter addTarget:self.mBrightFilter];
    [self.mBrightFilter addTarget:self.mGPUImageView];
        
    [self setupMovieWriter];

    [self.mCamera startCameraCapture];
}

- (void)setupMovieWriter {
    self.mMovieWriter = [[GPUImageMovieWriter alloc] initWithMovieURL:self.mOutputURL size:CGSizeMake(1080.0, 1920.0)];
    self.mMovieWriter.encodingLiveVideo = YES;
    self.mCamera.audioEncodingTarget = self.mMovieWriter;
}

#pragma mark - Property
- (GPUImageStillCamera *)mCamera {
    if (_mCamera == nil) {
        _mCamera = [[GPUImageStillCamera alloc]initWithSessionPreset:AVCaptureSessionPreset1920x1080 cameraPosition:AVCaptureDevicePositionBack];
        _mCamera.horizontallyMirrorFrontFacingCamera = YES;
        _mCamera.outputImageOrientation = UIInterfaceOrientationPortrait;
        [_mCamera openFlashWith:NO];
        [_mCamera setExposureMode:AVCaptureExposureModeContinuousAutoExposure];
        [_mCamera setExposurePoint:CGPointMake(0.5, 0.5)];
        [_mCamera tappedToFocusAtPoint:CGPointMake(0.5, 0.5)];
    }
    return _mCamera;
}

- (GPUImageView *)mGPUImageView {
    if (_mGPUImageView == nil) {
        _mGPUImageView = [[GPUImageView alloc] init];
        _mGPUImageView.frame = self.view.bounds;
        
        _mGPUImageView.fillMode = kGPUImageFillModePreserveAspectRatio;
        if (isIPhoneX) {
            _mGPUImageView.fillMode = kGPUImageFillModePreserveAspectRatioAndFill;
        }

        _mGPUImageView.userInteractionEnabled = YES;

        // 添加点击GPUImageView事件
        UITapGestureRecognizer *GPUImageViewTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(clickOnGPUImageView:)];
        [_mGPUImageView addGestureRecognizer:GPUImageViewTap];

        // 添加双击手势 用于切换前后镜头
        UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(clickGPUImageViewDoubleTap)];
        doubleTap.numberOfTapsRequired = 2;
        [_mGPUImageView addGestureRecognizer:doubleTap];
        [GPUImageViewTap requireGestureRecognizerToFail:doubleTap];

        // 添加捏合手势 用于放大缩小镜头
        UIPinchGestureRecognizer *pinchGesture = [[UIPinchGestureRecognizer alloc]initWithTarget:self action:@selector(clickGPUImageViewPinchTap:)];
        [_mGPUImageView addGestureRecognizer:pinchGesture];

        // 添加左右滑动的手势，用于修改lookuptable滤镜
        UISwipeGestureRecognizer *recognizerRight = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(handleSwipeFrom:)];
        recognizerRight.direction = UISwipeGestureRecognizerDirectionRight;
        recognizerRight.numberOfTouchesRequired = 1;

        UISwipeGestureRecognizer *recognizerLeft = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(handleSwipeFrom:)];
        recognizerLeft.direction = UISwipeGestureRecognizerDirectionLeft;
        recognizerLeft.numberOfTouchesRequired = 1;

        [_mGPUImageView addGestureRecognizer:recognizerRight];
        [_mGPUImageView addGestureRecognizer:recognizerLeft];
    }
    return _mGPUImageView;
}

- (NSURL *)mOutputURL {
    if (_mOutputURL == nil) {
        NSString *videoPath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:@"test.mp4"];
        _mOutputURL = [NSURL fileURLWithPath:videoPath];
    }
    return _mOutputURL;
}

- (UIButton *)pictureBtn {
    if (_pictureBtn == nil) {
        
        _pictureBtn = [UIButton buttonWithType:UIButtonTypeSystem];
        _pictureBtn.frame = CGRectMake(100, kSCREEN_HEIGHT - 80, 60, 40);
        [_pictureBtn setTitle:@"拍照" forState:UIControlStateNormal];
        [_pictureBtn addTarget:self action:@selector(clickPictureBtn) forControlEvents:UIControlEventTouchUpInside];
    }
    return _pictureBtn;
}

- (UIButton *)videoBtn {
    if (_videoBtn == nil) {
        _videoBtn = [UIButton buttonWithType:UIButtonTypeSystem];
        _videoBtn.frame = CGRectMake(kSCREEN_WIDTH - 160, kSCREEN_HEIGHT - 80, 60, 40);
        [_videoBtn setTitle:@"视频" forState:UIControlStateNormal];
        [_videoBtn setTitle:@"录制中" forState:UIControlStateSelected];
        [_videoBtn addTarget:self action:@selector(clickVideoBtn) forControlEvents:UIControlEventTouchUpInside];
    }
    return _videoBtn;
}

- (UIView *)focusView {
    if (_focusView == nil) {
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 160, 160)];
        view.backgroundColor = [UIColor clearColor];
        view.layer.borderColor = [UIColor orangeColor].CGColor;
        view.layer.borderWidth = 5.0f;
        view.hidden = YES;
        _focusView = view;
    }
    return _focusView;
}

@end
