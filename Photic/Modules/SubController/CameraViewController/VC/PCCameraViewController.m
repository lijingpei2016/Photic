//
//  PHCameraViewController.m
//  Photic
//
//  Created by LJP on 2022/8/22.
//

#import "PCCameraViewController.h"
#import "GPUImageBeautifyFilter.h"
#import <MBProgressHUD/MBProgressHUD.h>
#import "PCCameraMainView.h"

@interface PCCameraViewController ()<PCCameraMainViewDelegate>

@property (nonatomic, strong) GPUImageStillCamera *mCamera;
@property (nonatomic, weak) GPUImageView *mGPUImageView;

@property (nonatomic, strong) GPUImageBeautifyFilter *mBeautyFilter;
@property (nonatomic, strong) GPUImageBrightnessFilter *mBrightFilter;
@property (nonatomic, strong) GPUImageCropFilter *mCropFilter;

@property (nonatomic, strong) GPUImageLookupFilter *mLookupFilter;
@property (nonatomic, strong) GPUImagePicture *mLookupImageSource;
@property (nonatomic, strong) NSMutableArray *mLookupImageArr;
@property (nonatomic, assign) NSInteger currentLookupImageIndex;

@property (nonatomic, strong) GPUImageMovieWriter *mMovieWriter;
@property (nonatomic, strong) NSURL *mOutputURL;


@end

@implementation PCCameraViewController

#pragma mark - Lifecycle
- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupUI];
    [self setupCamera];
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
    self.view.backgroundColor = UIColor.blackColor;
    
    PCCameraMainView *mainView = [[PCCameraMainView alloc] initWithFrame:self.view.bounds];
    mainView.delegate = self;
    self.mGPUImageView = mainView.gpuImageView;
    [self.view addSubview:mainView];
}

- (void)setupCamera {
    self.mBeautyFilter = [[GPUImageBeautifyFilter alloc] init];
    self.mBrightFilter = [[GPUImageBrightnessFilter alloc] init];
    self.mBrightFilter.brightness = 0.01;
    self.mLookupFilter = [[GPUImageLookupFilter alloc]init];
    self.mLookupFilter.intensity = 0.5;
    [self setupLookupFilter];
    [self changeLookupFilter];
    self.mCropFilter = [[GPUImageCropFilter alloc] init];
    self.mCropFilter.cropRegion = CGRectMake(0, 0, 1, 1);
    
    [self.mCamera addTarget:self.mBeautyFilter];
    [self.mBeautyFilter addTarget:self.mBrightFilter];
    [self.mBrightFilter addTarget:self.mLookupFilter];
    [self.mLookupFilter addTarget:self.mCropFilter];
    [self.mCropFilter addTarget:self.mGPUImageView];
        
    [self setupMovieWriter];

    [self.mCamera startCameraCapture];
}

- (void)setupMovieWriter {
    self.mMovieWriter = [[GPUImageMovieWriter alloc] initWithMovieURL:self.mOutputURL size:CGSizeMake(1080.0, 1920.0)];
    self.mMovieWriter.encodingLiveVideo = YES;
    self.mCamera.audioEncodingTarget = self.mMovieWriter;
}

- (void)setupLookupFilter {
    self.mLookupImageArr = [[NSMutableArray alloc] init];
    NSString *file = [[NSBundle mainBundle] pathForResource:@"FilterNameAndType" ofType:@"plist"];
    NSDictionary *filterDict = [NSDictionary dictionaryWithContentsOfFile:file];
    NSArray *allFilterArr = filterDict[@"cameraFilter"];
    for (NSDictionary *tempDict in allFilterArr) {
        NSString *imageName = tempDict[@"imageName"];
        [self.mLookupImageArr addObject:imageName];
    }
}

///改变颜色滤镜效果
- (void)changeLookupFilter {
    NSString *imageName = self.mLookupImageArr[self.currentLookupImageIndex];

    if (_mLookupImageSource) {
        [self.mLookupImageSource removeAllTargets];
    }

    self.mLookupImageSource = [[GPUImagePicture alloc] initWithImage:[UIImage imageNamed:imageName]];
    [self.mLookupImageSource addTarget:self.mLookupFilter atTextureLocation:1];

    @try {
        [self.mLookupImageSource processImageWithCompletionHandler:^{
        }];
    } @catch (NSException *exception) {
        NSLog(@"crash---> %s, %@", __func__, exception.description);
    }
}

#pragma mark - PCCameraMainViewDelegate
- (void)clickScaleBtnWithScaleType:(PCCameraScaleType)type {
    switch (type) {
        case PCCameraScale916:
            self.mCropFilter.cropRegion = CGRectMake(0, 0, 1, 1);
            [self.mMovieWriter setNewVideoSize:CGSizeMake(1080.0, 1920.0)];
            break;
            
        case PCCameraScale169:
            self.mCropFilter.cropRegion = CGRectMake(0, 0, 1, 81 / 256.0);
            [self.mMovieWriter setNewVideoSize:CGSizeMake(1080.0, 1920.0 * 81 / 256.0)];
            break;
            
        case PCCameraScale11:
            self.mCropFilter.cropRegion = CGRectMake(0, 0, 1, 9 / 16.0);
            [self.mMovieWriter setNewVideoSize:CGSizeMake(1080.0, 1920.0 * 9 / 16.0)];
            break;
            
        case PCCameraScale43:
            self.mCropFilter.cropRegion = CGRectMake(0, 0, 1, 27 / 64.0);
            [self.mMovieWriter setNewVideoSize:CGSizeMake(1080.0, 1920.0 * 27 / 64.0)];
            break;
            
        case PCCameraScale34:
            self.mCropFilter.cropRegion = CGRectMake(0, 0, 1, 0.75);
            [self.mMovieWriter setNewVideoSize:CGSizeMake(1080.0, 1920.0 * 0.75)];
            break;
        default:
            break;
    }
}

- (void)clickPictureBtn {
    [self.mCamera capturePhotoAsImageProcessedUpToFilter:self.mCropFilter withCompletionHandler:^(UIImage *processedImage, NSError *error) {
        if (error) {
            NSLog(@"拍照失败");
            return;
        }
        UIImageWriteToSavedPhotosAlbum(processedImage, nil, nil, nil);
    }];
}

- (void)startRecording {
    unlink([self.mOutputURL.path UTF8String]);
    [self.mCamera isSmoothAutoFocusEnabledWith:YES];
    [self.mCropFilter addTarget:self.mMovieWriter];
    [self.mMovieWriter startRecording];
}

- (void)finishRecording {
    __weak typeof(self) weakSelf = self;
    [self.mMovieWriter finishRecordingWithCompletionHandler:^{
        [weakSelf.mCamera isSmoothAutoFocusEnabledWith:NO];
        [weakSelf.mBrightFilter removeTarget:weakSelf.mMovieWriter];
        [weakSelf setupMovieWriter];
        UISaveVideoAtPathToSavedPhotosAlbum(self.mOutputURL.path, nil, nil, nil);
    }];
}

- (void)focusAtPoint:(CGPoint)point {
    [self.mCamera tappedToFocusAtPoint:[self captureDevicePointForPoint:point]];
    [self.mCamera setExposurePoint:[self captureDevicePointForPoint:point]];
}

- (void)rotateCamera {
    [self.mCamera rotateCamera];
}

- (void)setCameraZoomFactor:(CGFloat)zoom {
    [self.mCamera setCameraZoomFactor:zoom];
}

- (void)leftSlip {
    if (self.currentLookupImageIndex == (self.mLookupImageArr.count - 1)) {
        self.currentLookupImageIndex = 0;
    } else {
        self.currentLookupImageIndex = self.currentLookupImageIndex + 1;
    }

    [self changeLookupFilter];
}

- (void)rightSlip {
    if (self.currentLookupImageIndex == 0) {
        self.currentLookupImageIndex = (NSInteger)self.mLookupImageArr.count - 1;
    } else {
        self.currentLookupImageIndex = self.currentLookupImageIndex - 1;
    }
    [self changeLookupFilter];
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

- (NSURL *)mOutputURL {
    if (_mOutputURL == nil) {
        NSString *videoPath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:@"test.mp4"];
        _mOutputURL = [NSURL fileURLWithPath:videoPath];
    }
    return _mOutputURL;
}

@end
