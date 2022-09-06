//
//  PCMovieComposition.h
//  Photic
//
//  Created by LJP on 2022/9/6.
//

#import <Foundation/Foundation.h>
#import "PCAVCropGroup.h"



typedef void (^progressCallBack)(float progress);
typedef void (^successCallBack)(void);
typedef void (^failCallBack)(NSError *error);

@interface PCMovieComposition : NSObject

- (instancetype)initWithAVGroup:(PCAVCropGroup *)avGroup outputURL:(NSURL *)outputURL;

- (void)composeWithSuccessCallBack:(successCallBack)successCallBack failCallBack:(failCallBack)failCallBack progressCallBack:(progressCallBack)progressCallBack;

@end

