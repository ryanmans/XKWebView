//
//  NSString+PS.h
//  PSWebView
//
//  Created by Ryan_Man on 16/6/27.
//  Copyright © 2016年 Ryan_Man. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (PS)
/**
 *  获取字符串的md5值
 *
 *  @return md5校验值
 */
- (NSString *)md5;


/**
 *  获取字符串的sha1值
 *
 *  @return sha1校验值
 */
- (NSString *)sha1;
@end
