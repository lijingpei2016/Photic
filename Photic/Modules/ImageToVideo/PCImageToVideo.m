//
//  PCImageToVideo.m
//  Photic
//
//  Created by LJP on 2022/8/26.
//

#import "PCImageToVideo.h"
#import "UIImage+ResizeSize.h"
#import <AVFoundation/AVFoundation.h>


@implementation PCImageToVideo

+ (void)createVideoWithImage:(UIImage *)image outputURL:(NSURL *)outputURL completeBlock:(void (^)(BOOL success))completeBlock {
    
    if (image == nil) {
        NSLog(@"image == nil");
        return;
    }
    
    if (outputURL == nil || outputURL.path.length == 0) {
        NSLog(@"outputURL == nil");
        return;
    }
    
    unlink([outputURL.path UTF8String]);

    CGSize size = image.size;
    if (size.width > 1280 || size.height > 1280) {
        CGFloat rate = 1280 / MAX(size.width, size.height);
        image = [image jp_imageByResizeToSize:CGSizeMake(size.width *rate, size.height *rate)];
        size = image.size;
    }

    NSError *error = nil;
    
    AVAssetWriter *videoWriter = [[AVAssetWriter alloc] initWithURL:outputURL fileType:AVFileTypeQuickTimeMovie error:&error];
    
    if (error) {
        NSLog(@"error = %@", [error localizedDescription]);
        if (completeBlock) {
            completeBlock(NO);
        }
        return;
    }

    NSDictionary *videoSettings = @{ AVVideoCodecKey: AVVideoCodecTypeH264,
                                     AVVideoWidthKey: @(size.width),
                                     AVVideoHeightKey: @(size.height),
                                     };

    AVAssetWriterInput *writerInput = [AVAssetWriterInput assetWriterInputWithMediaType:AVMediaTypeVideo outputSettings:videoSettings];

    NSDictionary *sourcePixelBufferAttributesDictionary = @{ (id)kCVPixelBufferPixelFormatTypeKey: @(kCVPixelFormatType_32ARGB) };

    AVAssetWriterInputPixelBufferAdaptor *adaptor = [AVAssetWriterInputPixelBufferAdaptor assetWriterInputPixelBufferAdaptorWithAssetWriterInput:writerInput sourcePixelBufferAttributes:sourcePixelBufferAttributesDictionary];

    NSParameterAssert(writerInput);
    NSParameterAssert([videoWriter canAddInput:writerInput]);

    [videoWriter addInput:writerInput];
    [videoWriter startWriting];
    [videoWriter startSessionAtSourceTime:kCMTimeZero];

    dispatch_queue_t dispatchQueue = dispatch_queue_create(NULL, NULL);
    
    __block int frame = -1;
    CVPixelBufferRef buffer = [self pixelBufferFromCGImage:image.CGImage];
    [writerInput requestMediaDataWhenReadyOnQueue:dispatchQueue usingBlock:^{
        while ([writerInput isReadyForMoreMediaData]) {
            if (++frame >= 90) {
                [writerInput markAsFinished];
                [videoWriter finishWritingWithCompletionHandler:^{
                    CFRelease(buffer);
                    if (completeBlock) {
                        completeBlock(YES);
                    }
                }];
                break;
            }

            if (buffer) {
                //设置每秒钟播放图片的个数
                BOOL success = [adaptor appendPixelBuffer:buffer withPresentationTime:CMTimeMake(frame, 30)];
                if (!success) {
                    NSLog(@"生成Buffer失败");
                    NSLog(@"outputURL = %@",outputURL);
                    if (completeBlock) {
                        completeBlock(NO);
                    }
                    break;
                }
            }
        }
    }];
}

+ (CVPixelBufferRef)pixelBufferFromCGImage:(CGImageRef)image {
    NSDictionary *options = @{
                              (NSString*)kCVPixelBufferCGImageCompatibilityKey : @YES,
                              (NSString*)kCVPixelBufferCGBitmapContextCompatibilityKey : @YES,
                              (NSString*)kCVPixelBufferIOSurfacePropertiesKey: [NSDictionary dictionary]
                              };
    CVPixelBufferRef pxbuffer = NULL;
    
    CGFloat frameWidth = CGImageGetWidth(image);
    CGFloat frameHeight = CGImageGetHeight(image);
    
    CVReturn status = CVPixelBufferCreate(kCFAllocatorDefault,
                                          frameWidth,
                                          frameHeight,
                                          kCVPixelFormatType_32ARGB,
                                          (__bridge CFDictionaryRef) options,
                                          &pxbuffer);
    
    NSParameterAssert(status == kCVReturnSuccess && pxbuffer != NULL);
    
    CVPixelBufferLockBaseAddress(pxbuffer, 0);
    void *pxdata = CVPixelBufferGetBaseAddress(pxbuffer);
    NSParameterAssert(pxdata != NULL);
    
    CGColorSpaceRef rgbColorSpace = CGColorSpaceCreateDeviceRGB();
    
    CGContextRef context = CGBitmapContextCreate(pxdata,
                                                 frameWidth,
                                                 frameHeight,
                                                 8,
                                                 CVPixelBufferGetBytesPerRow(pxbuffer),
                                                 rgbColorSpace,
                                                 (CGBitmapInfo)kCGImageAlphaPremultipliedFirst);
    NSParameterAssert(context);
    CGContextConcatCTM(context, CGAffineTransformIdentity);
    CGContextDrawImage(context, CGRectMake(0,
                                           0,
                                           frameWidth,
                                           frameHeight),
                       image);
    CGColorSpaceRelease(rgbColorSpace);
    CGContextRelease(context);
    
    CVPixelBufferUnlockBaseAddress(pxbuffer, 0);
    
    return pxbuffer;
}

@end
