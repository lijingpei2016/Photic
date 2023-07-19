//
//  GPUThinFaceAndLargeEyeFilter.h
//  Photic
//
//  Created by LJP on 2023/7/20.
//

#import "GPUImageFilter.h"

NS_ASSUME_NONNULL_BEGIN

@interface GPUThinFaceAndBigEyeFilter : GPUImageFilter

@property (nonatomic, strong) NSArray<NSValue *> *points;

@property (nonatomic, assign) CGFloat thinFaceValue;
@property (nonatomic, assign) CGFloat bigEyeValue;

@end

NS_ASSUME_NONNULL_END
