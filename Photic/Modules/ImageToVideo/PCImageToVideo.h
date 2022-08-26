//
//  PCImageToVideo.h
//  Photic
//
//  Created by LJP on 2022/8/26.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface PCImageToVideo : NSObject

+ (void)createVideoWithImage:(UIImage *)image outputURL:(NSURL *)outputURL completeBlock:(void (^)(BOOL success))completeBlock;

@end

NS_ASSUME_NONNULL_END
