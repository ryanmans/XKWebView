//
//  PSUrlCache.m
//  PSWebView
//
//  Created by Ryan_Man on 16/6/27.
//  Copyright © 2016年 Ryan_Man. All rights reserved.
//

#import "PSUrlCache.h"

@interface PSUrlCache ()
@property(nonatomic, retain) NSMutableDictionary *responseDictionary;
@property (nonatomic,strong)NSFileManager * fileManager;
@end

@implementation PSUrlCache
@synthesize cacheTime = _cacheTime;
@synthesize diskPath = _diskPath;

- (id)initWithMemoryCapacity:(NSUInteger)memoryCapacity diskCapacity:(NSUInteger)diskCapacity diskPath:(NSString *)path cacheTime:(NSInteger)cacheTime
{
    //默认情况下，内存是4M，4* 1024 * 1024；Disk为20M，20 * 1024 ＊ 1024
    if (self = [super initWithMemoryCapacity:memoryCapacity diskCapacity:diskCapacity diskPath:path])
    {
        self.cacheTime = cacheTime;
        if (path) {
            self.diskPath = path;
        }else
        {
            //cache 路径
            self.diskPath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
        }
        
        NSLog(@"diskPath : %@",_diskPath);
        
        self.responseDictionary = [NSMutableDictionary dictionary];
    }
    return self;
}

- (NSFileManager*)fileManager
{
    if (!_fileManager) {
        _fileManager = [NSFileManager defaultManager];
    }
    return _fileManager;
}

#pragma mark --
- (void)removeAllCachedResponses
{
    [super removeAllCachedResponses];
    
    [self deleteCacheFolder];
}

- (void)removeCachedResponseForRequest:(NSURLRequest *)request
{
    [super removeCachedResponseForRequest:request];
    
    NSString * urlString = request.URL.absoluteString;
    
    NSString * filePath = [self filePath:urlString];
    NSString * otherInfoFilePath = [self otherInfoFilePath:urlString];
    
    [self.fileManager removeItemAtPath:filePath error:nil];
    [self.fileManager removeItemAtPath:otherInfoFilePath error:nil];
}

- (NSCachedURLResponse*)cachedResponseForRequest:(NSURLRequest *)request
{
    
    if ([request.HTTPMethod compare:@"GET"] != NSOrderedSame)
    {
        return [super cachedResponseForRequest:request];
    }
    return [self dataFromRequest:request];
}

- (NSString*)filePath:(NSString*)urlString
{
    NSString * fileName = [self cacheRequestFileName:urlString];
    return [self cacheFilePath:fileName];
}

- (NSString*)otherInfoFilePath:(NSString*)urlString
{
    NSString * otherInfoFileName = [self cacheRequestOtherInfoFileName:urlString];
    return [self cacheFilePath:otherInfoFileName];
}
#pragma mark - private method-

//文件名
- (NSString *)cacheFolder
{
    return @"PSUrlCache";
}

- (NSString *)cacheFilePath:(NSString *)file
{
    NSString *path = [NSString stringWithFormat:@"%@/%@", self.diskPath, [self cacheFolder]];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL isDir;
    if ([fileManager fileExistsAtPath:path isDirectory:&isDir] && isDir) {
        
    } else {
        [fileManager createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];
    }
    return [NSString stringWithFormat:@"%@/%@", path, file];
}

// 网络 文件加密数据
- (NSString *)cacheRequestFileName:(NSString *)requestUrl
{
    return requestUrl.md5;
}

//获取配置文件 加密数据
- (NSString *)cacheRequestOtherInfoFileName:(NSString *)requestUrl
{
    NSString * string = [NSString stringWithFormat:@"%@-otherInfo", requestUrl];
    return string.md5;
}

//数据加载
- (NSCachedURLResponse *)dataFromRequest:(NSURLRequest *)request
{
    __block NSString * urlString = request.URL.absoluteString;
    
    NSString * filePath = [self filePath:urlString];
    NSString * otherInfoFilePath = [self otherInfoFilePath:urlString];

    NSDate * date = [NSDate date];
    
    //先检测本地是否存在
    if ([self.fileManager fileExistsAtPath:filePath])
    {
        BOOL expire = NO;
        
        // 获取配置的数据
        NSDictionary * otherInfoDict = [NSDictionary dictionaryWithContentsOfFile:otherInfoFilePath];
        
        if (self.cacheTime > 0)
        {
            //比较时间，查看是否到期
            NSInteger  createTime = [[otherInfoDict objectForKey:@"time"] integerValue];
            if (createTime + self.cacheTime < [date timeIntervalSince1970])
            {
                expire = YES;
            }
        }
        
        //还在缓存期间。读取本地缓存数据
        if (expire == NO)
        {
            NSLog(@"data from PSCache......");
            
            NSData * fileData = [NSData dataWithContentsOfFile:filePath];
            
            NSURLResponse *response = [[NSURLResponse alloc] initWithURL:request.URL
                                                                MIMEType:[otherInfoDict objectForKey:@"MIMEType"]
                                                   expectedContentLength:fileData.length
                                                        textEncodingName:[otherInfoDict objectForKey:@"textEncodingName"]];
            
            NSCachedURLResponse *cachedResponse = [[NSCachedURLResponse alloc] initWithResponse:response data:fileData];
            return cachedResponse;
            
        }
        else
        {
            //缓存到期，清除缓存（须download）
            
            NSLog(@"PSCache.. expire ....");

            [self.fileManager removeItemAtPath:filePath error:nil];
            [self.fileManager removeItemAtPath:otherInfoFilePath error:nil];
        }
        
    }
    
    //检测当前网络
    if (![Reachability networkAvailable]) {
        return nil;
    }
    
    __block NSCachedURLResponse * cacheResponse = nil;
    
    id object = [self.responseDictionary objectForKey:urlString];
    if (!object)
    {
        [self.responseDictionary setValue:[NSNumber numberWithBool:YES] forKey:urlString];
        
        __weak typeof(self) ws = self;
        
        [NSURLConnection sendAsynchronousRequest:request queue:[[NSOperationQueue alloc] init] completionHandler:^(NSURLResponse * _Nullable response, NSData * _Nullable data, NSError * _Nullable connectionError) {
            
            if (response && data)
            {
               
                [ws.responseDictionary removeObjectForKey:urlString];
                
                if ( connectionError)
                {
                    NSLog(@"error : %@",connectionError);
                    NSLog(@"not PSCache ,url:%@ ",urlString);
                    cacheResponse = nil;
                }
                
                NSLog(@"request Url : %@",urlString);
                
                // save data to cache
                
                NSDictionary * temp = @{@"time":[NSString stringWithFormat:@"%f", [date timeIntervalSince1970]],@"MIMEType":IsSafeString(response.MIMEType),@"textEncodingName":IsSafeString(response.textEncodingName)};
                
                [data writeToFile:filePath atomically:YES];
                
                [temp writeToFile:otherInfoFilePath atomically:YES];
                
                cacheResponse = [[NSCachedURLResponse alloc] initWithResponse:response data:data];

            }
        }];
        
        return cacheResponse;
    }
    
    return nil;
}

//删除缓存目录
- (void)deleteCacheFolder
{
    NSString *path = [NSString stringWithFormat:@"%@/%@", self.diskPath, [self cacheFolder]];
    [self.fileManager removeItemAtPath:path error:nil];
}
@end
