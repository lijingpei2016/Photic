//
//  UIImage+ResizeSize.m
//  Photic
//
//  Created by LJP on 2022/8/26.
//

#import "UIImage+ResizeSize.h"

@implementation UIImage (ResizeSize)

- (UIImage *)jp_imageByResizeToSize:(CGSize)size {
    if (size.width <= 0 || size.height <= 0) return nil;
    UIGraphicsBeginImageContextWithOptions(size, NO, self.scale);
    [self drawInRect:CGRectMake(0, 0, size.width, size.height)];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

@end
