//
//  PhoticHeader.h
//  Photic
//
//  Created by LJP on 2022/8/22.
//

#ifndef PhoticHeader_h
#define PhoticHeader_h


#define isIPhoneX           ((kSCREEN_WIDTH == 375.f && kSCREEN_WIDTH == 812.f) ? YES : NO)

#define kBottomMargan       (isIphoneFullScreen ? 34.f : 0.f)
#define kBottomBarHeight    (isIphoneFullScreen ? (49.f + 34.f) : 49.f)
#define kStatusBarHeight    (isIphoneFullScreen ? 44.f : 0.f)

// 字体大小的简写
#define kFont(font) [UIFont systemFontOfSize:font]
#define kBFont(font) [UIFont boldSystemFontOfSize:font]


//UI相关
#define kSCREEN_BOUNDS       ([[UIScreen mainScreen] bounds])
#define kSCREEN_WIDTH        ([[UIScreen mainScreen] bounds].size.width)
#define kSCREEN_HEIGHT       ([[UIScreen mainScreen] bounds].size.height)
#define kSCREEN_FRAME        ([[UIScreen mainScreen] applicationFrame])
#define kWIDTH_375_RATE      ([[UIScreen mainScreen] bounds].size.width / 375.0)
#define kWIDTH_750_RATE      ([[UIScreen mainScreen] bounds].size.width / 750.0)
#define kHEIGHT_667_RATE      ([[UIScreen mainScreen] bounds].size.height / 667.0)
#define kWIDTH_750RATE(value)      ((value)*([[UIScreen mainScreen] bounds].size.width / 750.0))

//码率
#define kVideoBitRatePreset 7.2 //7.2 10s、1080p、30帧视频的比特率大概为15000kbps，大小为18MB-19MB左右

#define kDefaultVideoPrefixPath [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject]

#define CLog(format, ...) LogInternal(kLevelInfo, "photic", __FILENAME__, __LINE__, __FUNCTION__, @"]\n", format, ##__VA_ARGS__)

#endif


//比例枚举
#define PCScale916 (1)
#define PCScale169 (2)
#define PCScale11  (3)
#define PCScale43  (4)
#define PCScale34  (5)


