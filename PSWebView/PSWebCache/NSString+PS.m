//
//  NSString+PS.m
//  PSWebView
//
//  Created by Ryan_Man on 16/6/27.
//  Copyright © 2016年 Ryan_Man. All rights reserved.
//

#import "NSString+PS.h"
#import <CommonCrypto/CommonDigest.h>

@implementation NSString (PS)

- (NSString *)md5
{
    const char* utfStr = self.UTF8String;
    unsigned char md[16] = {0};
    CC_MD5(utfStr,(CC_LONG)strlen(utfStr),md);
    char szOutput[33] = { 0 };
    for (int index = 0; index < 16; index++) {
        unsigned char src = md[index];
        sprintf(szOutput, "%s%02x",szOutput,src);
    }
    return [NSString stringWithUTF8String:szOutput];
}

- (NSString *)sha1
{
    const char* utfStr = self.UTF8String;
    unsigned char md[20] = {0};
    CC_SHA1(utfStr,(CC_LONG)strlen(utfStr),md);
    char szOutput[41] = { 0 };
    for (int index = 0; index < 20; index++)
    {
        unsigned char src = md[index];
        sprintf(szOutput, "%s%02x",szOutput,src);
    }
    return [NSString stringWithUTF8String:szOutput];
}

@end
