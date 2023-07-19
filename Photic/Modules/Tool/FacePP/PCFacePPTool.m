//
//  PCFacePPTool.m
//  Photic
//
//  Created by LJP on 2023/7/20.
//

#define kFacePPApiKey    @""
#define kFacePPApiSecret @""
#define kFacePPAuthURL   @"https://api-cn.faceplusplus.com/sdk/v3/auth"

#import "PCFacePPTool.h"
#import <MGFacePPMultiBase/MGFacePPMultiBase.h>

@implementation PCFacePPTool

+ (void)setupFacePPConfig {
    NSString *modelPath = [[NSBundle mainBundle] pathForResource:@"megviifacepp_model" ofType:@""];
    MGFPPErrorCode retcode = [[MGFaceHandleManager sharedInstance] createHandleWithModelPath:modelPath];
    if (retcode) {
        PCLog(@"face++ 加载模型 == %zd", retcode);
        return;
    }

    //联网授权
    NSString *version = [[MGFaceHandleManager sharedInstance] getApiName];
    NSString *uuid = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
    [MGFacePPLicenseManager getLicenseWithUUID:uuid
                                     modelPath:modelPath
                                       version:version
                                        apiKey:kFacePPApiKey
                                     apiSecret:kFacePPApiSecret
                                   apiDuration:MGAPIDurationDay
                                     URLString:kFacePPAuthURL
                                        finish:^(bool License, NSError *_Nonnull error) {
        PCLog(@"初始化 face++ %@", License ? @"成功" : @"失败");
        if (error) {
            PCLog(@"error == %@", error);
        }
    }];
}

@end
