//
//  PCCameraMainView.h
//  Photic
//
//  Created by LJP on 2022/8/31.
//

typedef enum {
    PCCameraScale916 = PCScale916,
    PCCameraScale169 = PCScale169,
    PCCameraScale11  = PCScale11,
    PCCameraScale43  = PCScale43,
    PCCameraScale34  = PCScale34
} PCCameraScaleType;

#import <UIKit/UIKit.h>
#import "GPUImage.h"

//代理
@protocol PCCameraMainViewDelegate <NSObject>

- (void)clickScaleBtnWithScaleType:(PCCameraScaleType)type;
- (void)clickPictureBtn;
- (void)startRecording;
- (void)finishRecording;
- (void)focusAtPoint:(CGPoint)point;
- (void)rotateCamera;
- (void)setCameraZoomFactor:(CGFloat)zoom;
- (void)leftSlip;
- (void)rightSlip;

@end


NS_ASSUME_NONNULL_BEGIN

@interface PCCameraMainView : UIView

@property (nonatomic, strong) GPUImageView *gpuImageView;
@property (nonatomic, weak) id<PCCameraMainViewDelegate> delegate;

@end

NS_ASSUME_NONNULL_END
