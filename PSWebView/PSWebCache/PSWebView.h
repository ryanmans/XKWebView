//
//  PSWebView.h
//  PSWebView
//
//  Created by Ryan_Man on 16/6/27.
//  Copyright © 2016年 Ryan_Man. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PSUrlCache.h"
@interface PSWebView : UIView
@property (nonatomic,strong,readonly)PSUrlCache * urlCache;
@property (nonatomic,strong,readonly)UIWebView * webView;

/**
 *  加载网络页面
 *
 *  @param UrlString
 */
- (void)loadRequest:(NSString*)UrlString;

/**
 *  清空网页缓存
 */
- (void)cleanRequestCache;
@end
