//
//  UIImage+ResizeSize.h
//  Photic
//
//  Created by LJP on 2022/8/26.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIImage (ResizeSize)

- (UIImage *)jp_imageByResizeToSize:(CGSize)size;

@end

NS_ASSUME_NONNULL_END
