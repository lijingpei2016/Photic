//
//  GPUImageBeautifyFilter.h
//  WWTita
//
//  Created by LJP on 2019/4/15.
//  Copyright © 2019 wewave Inc. All rights reserved.
//

#import "GPUImage.h"

@class GPUImageCombinationFilter;

@interface GPUImageBeautifyFilter : GPUImageFilterGroup

@property (nonatomic, strong)GPUImageBilateralFilter *bilateralFilter;
@property (nonatomic, strong)GPUImageCannyEdgeDetectionFilter *cannyEdgeFilter;
@property (nonatomic, strong)GPUImageCombinationFilter *combinationFilter;
@property (nonatomic, strong)GPUImageHSBFilter *hsbFilter;

@property (nonatomic, assign)CGFloat combinationValue;

@end
