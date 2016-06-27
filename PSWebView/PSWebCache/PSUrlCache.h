//
//  PSUrlCache.h
//  PSWebView
//
//  Created by Ryan_Man on 16/6/27.
//  Copyright © 2016年 Ryan_Man. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PSUrlCache : NSURLCache
/**
 *  缓存时长
 */
@property (nonatomic,assign)NSInteger cacheTime;
/**
 *  硬盘路径
 */
@property (nonatomic,copy)NSString * diskPath;

- (id)initWithMemoryCapacity:(NSUInteger)memoryCapacity diskCapacity:(NSUInteger)diskCapacity diskPath:(NSString *)path cacheTime:(NSInteger)cacheTime;

@end
