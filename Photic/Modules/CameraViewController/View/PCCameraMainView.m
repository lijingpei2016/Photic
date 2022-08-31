//
//  PCCameraMainView.h
//  Photic
//
//  Created by LJP on 2022/8/31.
//

#import "PCCameraMainView.h"

@interface PCCameraMainView ()

/// 镜头缩放系数
@property (nonatomic, assign) CGFloat cameraZoom;

/// 焦点框
@property (nonatomic, strong) UIView *focusView;

/// 拍照
@property (nonatomic, strong) UIButton *pictureBtn;

/// 拍视频
@property (nonatomic, strong) UIButton *videoBtn;

@end

@implementation PCCameraMainView

#pragma mark - Lifecycle
- (instancetype)init
{
    self = [super init];
    if (self) {
        [self setupUI];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupUI];
    }
    return self;
}

- (void)setupUI {
    [self addSubview:self.gpuImageView];
    [self addSubview:self.videoBtn];
    [self addSubview:self.pictureBtn];
    [self addSubview:self.focusView];
    [self setupScaleButtons];
}

- (void)setupScaleButtons {
    NSArray <NSString *>*buttonNameArr = @[@"9:16", @"16:9", @"1:1", @"4:3", @"3:4"];
    NSArray <NSNumber *>*buttonTagArr = @[@(PCScale916), @(PCScale169), @(PCScale11), @(PCScale43), @(PCScale34)];
    CGFloat gap = (kSCREEN_WIDTH - 40 - 50 * buttonNameArr.count) / (buttonNameArr.count - 1);
    for (int i = 0; i < buttonNameArr.count; i++) {
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeSystem];
        btn.frame = CGRectMake(20 + i * (gap + 50) , 90, 50, 40);
        [btn setTitle:buttonNameArr[i] forState:UIControlStateNormal];
        [btn setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
        [btn addTarget:self action:@selector(clickScaleBtn:) forControlEvents:UIControlEventTouchUpInside];
        btn.tag = buttonTagArr[i].intValue + 100;
        [self addSubview:btn];
    }
}

#pragma mark - Action
- (void)clickScaleBtn:(UIButton *)btn {
    if (self.delegate && [self.delegate respondsToSelector:@selector(clickScaleBtnWithScaleType:)]) {
        PCCameraScaleType type = btn.tag - 100;
        [self.delegate clickScaleBtnWithScaleType:type];
    }
}

///改变颜色滤镜效果
- (void)changeLookupFilter {

}

///左右滑动手势
- (void)handleSwipeFrom:(UISwipeGestureRecognizer *)recognizer {

}


- (void)clickOnGPUImageView:(UIGestureRecognizer *)recognizer {
    if (self.delegate && [self.delegate respondsToSelector:@selector(focusAtPoint:)]) {
        CGPoint point = [recognizer locationInView:self.gpuImageView];
        [self runBoxAnimationOnView:self.focusView point:point];
        [self.delegate focusAtPoint:point];
    }
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
    if (self.delegate && [self.delegate respondsToSelector:@selector(rotateCamera)]) {
        [self.delegate rotateCamera];
    }
}

///捏合手势
- (void)clickGPUImageViewPinchTap:(UIPinchGestureRecognizer *)recognizer {
    if (self.delegate && [self.delegate respondsToSelector:@selector(setCameraZoomFactor:)]) {
        CGFloat changeScale = recognizer.scale;
        self.cameraZoom = self.cameraZoom * changeScale;
        self.cameraZoom = MAX(self.cameraZoom, 1.0);
        self.cameraZoom = MIN(self.cameraZoom, 10.0);
        
        [self.delegate setCameraZoomFactor:self.cameraZoom];
        
        recognizer.scale = 1.0;
    }
}

- (void)clickPictureBtn {
    NSLog(@"拍照");
    if (self.delegate && [self.delegate respondsToSelector:@selector(clickPictureBtn)]) {
        [self.delegate clickPictureBtn];
    }
}

- (void)clickVideoBtn {
    
    self.videoBtn.selected = !self.videoBtn.selected;
    
    if(self.videoBtn.isSelected) {
        NSLog(@"开始录制");
        if (self.delegate && [self.delegate respondsToSelector:@selector(startRecording)]) {
            [self.delegate startRecording];
        }
    }else {
        NSLog(@"结束录制");
        if (self.delegate && [self.delegate respondsToSelector:@selector(finishRecording)]) {
            [self.delegate finishRecording];
        }
    }
}


#pragma mark - Property
- (GPUImageView *)gpuImageView {
    if (_gpuImageView == nil) {
        _gpuImageView = [[GPUImageView alloc] init];
        _gpuImageView.frame = self.bounds;
        
        _gpuImageView.fillMode = kGPUImageFillModePreserveAspectRatio;
        if (isIPhoneX) {
            _gpuImageView.fillMode = kGPUImageFillModePreserveAspectRatioAndFill;
        }

        _gpuImageView.userInteractionEnabled = YES;

        // 添加点击GPUImageView事件
        UITapGestureRecognizer *GPUImageViewTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(clickOnGPUImageView:)];
        [_gpuImageView addGestureRecognizer:GPUImageViewTap];

        // 添加双击手势 用于切换前后镜头
        UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(clickGPUImageViewDoubleTap)];
        doubleTap.numberOfTapsRequired = 2;
        [_gpuImageView addGestureRecognizer:doubleTap];
        [GPUImageViewTap requireGestureRecognizerToFail:doubleTap];

        // 添加捏合手势 用于放大缩小镜头
        UIPinchGestureRecognizer *pinchGesture = [[UIPinchGestureRecognizer alloc]initWithTarget:self action:@selector(clickGPUImageViewPinchTap:)];
        [_gpuImageView addGestureRecognizer:pinchGesture];

        // 添加左右滑动的手势，用于修改查色表滤镜
        UISwipeGestureRecognizer *recognizerRight = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(handleSwipeFrom:)];
        recognizerRight.direction = UISwipeGestureRecognizerDirectionRight;
        recognizerRight.numberOfTouchesRequired = 1;

        UISwipeGestureRecognizer *recognizerLeft = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(handleSwipeFrom:)];
        recognizerLeft.direction = UISwipeGestureRecognizerDirectionLeft;
        recognizerLeft.numberOfTouchesRequired = 1;

        [_gpuImageView addGestureRecognizer:recognizerRight];
        [_gpuImageView addGestureRecognizer:recognizerLeft];
    }
    return _gpuImageView;
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
