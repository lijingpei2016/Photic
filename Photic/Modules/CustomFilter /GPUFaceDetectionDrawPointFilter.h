//
//  GPUFaceDetectionDrawPointFilter.h
//  Photic
//
//  Created by LJP on 2023/7/20.
//

#import "GPUImageFilter.h"

NS_ASSUME_NONNULL_BEGIN

@interface GPUFaceDetectionDrawPointFilter : GPUImageFilter

@property (nonatomic, strong) NSArray<NSValue *> *points;

@end

NS_ASSUME_NONNULL_END
