//
//  PCFaceDetectionViewController.m
//  Photic
//
//  Created by LJP on 2023/7/19.
//

#import "PCFaceDetectionViewController.h"
#import "GPUImage.h"
#import <MGFacePPFaceDetect/MGFacePPFaceDetect.h>
#import "GPUFaceDetectionDrawPointFilter.h"
#import "GPUThinFaceAndBigEyeFilter.h"

@interface PCThinFaceAndBigEyeViewController ()<GPUImageVideoCameraDelegate>

@property (nonatomic, strong) GPUImageView *mGPUImageView;
@property (nonatomic, strong) GPUImageStillCamera *mCamera;

@property (nonatomic, strong) MGFaceDetectManager *detectManager;
@property (nonatomic, strong) MGFacePPImage *ppImage;

@property (nonatomic, strong) dispatch_queue_t renderQueue;
@property (nonatomic, strong) GPUFaceDetectionDrawPointFilter *drawFilter;
@property (nonatomic, strong) GPUThinFaceAndBigEyeFilter *effectFilter;

@property (nonatomic, strong) UISlider *faceSlider;
@property (nonatomic, strong) UISlider *eyeSlider;

@end

@implementation PCThinFaceAndBigEyeViewController

#pragma mark - Lifecycle
- (void)dealloc {
    PCLog(@"%s", __func__);
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupUI];
    [self setFaceDetectConfig];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self setupCamera];
    });
}

#pragma mark - Private Method
- (void)setupUI {
    self.view.backgroundColor = UIColor.blackColor;
    [self.view addSubview:self.mGPUImageView];

    self.faceSlider = [[UISlider alloc] initWithFrame:CGRectMake(20, self.view.frame.size.height - 90, self.view.frame.size.width - 40, 30)];
    self.faceSlider.minimumValue = 0;
    self.faceSlider.maximumValue = 0.05;
    [self.faceSlider addTarget:self action:@selector(sliderChange:) forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:self.faceSlider];

    self.eyeSlider = [[UISlider alloc] initWithFrame:CGRectMake(20, self.view.frame.size.height - 140, self.view.frame.size.width - 40, 30)];
    self.eyeSlider.minimumValue = 0;
    self.eyeSlider.maximumValue = 0.3;
    [self.eyeSlider addTarget:self action:@selector(sliderChange:) forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:self.eyeSlider];
}

- (void)setupCamera {
    self.drawFilter = [[GPUFaceDetectionDrawPointFilter alloc] init];
    self.effectFilter = [[GPUThinFaceAndBigEyeFilter alloc] init];

    [self.mCamera addTarget:self.drawFilter];
    [self.drawFilter addTarget:self.effectFilter];
    [self.effectFilter addTarget:self.mGPUImageView];
    [self.mCamera startCameraCapture];
}

- (void)setFaceDetectConfig {
    MGFPPErrorCode error;
    self.detectManager = [[MGFaceDetectManager alloc] initWithErrorCode:&error];
    if (error) {
        PCLog(@"初始化人脸检测失败 code == %ld", error);
        return;
    }

    MGFaceDetectConfig *config = [[MGFaceDetectConfig alloc] init];
    [self.detectManager getDetectConfig:config];
    config.detectionMode = MGFaceDetectionMode_tracking;
    config.faceConfidenceFilter = 0.1;
    config.minFaceSize = 100;
    Rect rect = { 0, 0, 0, 0 };
    config.roi = rect;
    error = [self.detectManager setDetectConfig:config];

    if (error) {
        PCLog(@"配置人脸检测失败 code == %ld", error);
        return;
    }

    PCLog(@"配置人脸检测成功");

    self.ppImage = [[MGFacePPImage alloc] init];
    self.renderQueue = dispatch_queue_create("com.megvii.render", DISPATCH_QUEUE_SERIAL);
}

- (CGPoint)transformPointToPortrait:(CGPoint)point {
    return CGPointMake(point.y / 720.0, point.x / 1280.0 - 0.1);
}

#pragma mark - Public Method

#pragma mark - Action
- (void)sliderChange:(UISlider *)slider {
    if (slider == self.faceSlider) {
        self.effectFilter.thinFaceValue = slider.value;
    } else {
        self.effectFilter.bigEyeValue = slider.value;
    }
}

#pragma mark - Delegate
#pragma mark - GPUImageVideoCameraDelegate
- (void)willOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer {
    dispatch_sync(_renderQueue, ^{
        [_ppImage setSampleBuffer:sampleBuffer imageMode:MGFacePPImageMode_GRAY orientation:MGFacePPOrientation_UP];

        int faceCount = 0;
        MGFPPErrorCode errcode = [self.detectManager detectFace:_ppImage faceCount:&faceCount];
        if (errcode) {
            PCLog(@"人脸检测失败 code == %ld", errcode);
            [self.ppImage releaseImageData];
            return;
        }

        if (faceCount) {
            MGFaceInfo *faceinfo = [self.detectManager getFaceInfoWithFaceIndex:0];
            errcode = [self.detectManager getLandmarkWithLandmarkType:MGLandmarkType_106 isSmooth:YES result:faceinfo];
            if (errcode) {
                PCLog(@"获取指定人脸信息检测失败 code == %ld", errcode);
                [self.ppImage releaseImageData];
                return;
            }

            NSMutableArray *points = [NSMutableArray array];
            for (MGFacePPPoint *temp in faceinfo.points) {
                CGPoint point = [self transformPointToPortrait:CGPointMake(temp.x, temp.y)];
                [points addObject:[NSValue valueWithCGPoint:point]];
            }

            self.drawFilter.points = points;
            self.effectFilter.points = points;
        }

        [self.ppImage releaseImageData];
    });
}

#pragma mark - Property
- (GPUImageView *)mGPUImageView {
    if (_mGPUImageView == nil) {
        _mGPUImageView = [[GPUImageView alloc] initWithFrame:self.view.bounds];
        _mGPUImageView.fillMode = kGPUImageFillModePreserveAspectRatio;
    }
    return _mGPUImageView;
}

- (GPUImageStillCamera *)mCamera {
    if (_mCamera == nil) {
        _mCamera = [[GPUImageStillCamera alloc]initWithSessionPreset:AVCaptureSessionPreset1280x720 cameraPosition:AVCaptureDevicePositionFront];
        _mCamera.horizontallyMirrorFrontFacingCamera = YES;
        _mCamera.outputImageOrientation = UIInterfaceOrientationPortrait;
        [_mCamera openFlashWith:NO];
        [_mCamera setExposureMode:AVCaptureExposureModeContinuousAutoExposure];
        [_mCamera setExposurePoint:CGPointMake(0.5, 0.5)];
        [_mCamera tappedToFocusAtPoint:CGPointMake(0.5, 0.5)];
        _mCamera.delegate = self;
    }
    return _mCamera;
}

@end
