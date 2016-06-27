//
//  PSWebView.m
//  PSWebView
//
//  Created by Ryan_Man on 16/6/27.
//  Copyright © 2016年 Ryan_Man. All rights reserved.
//

#import "PSWebView.h"

#define MemoryCacheCap    4 * 1024 * 1024

@interface PSWebView ()<UIWebViewDelegate>
@end
@implementation PSWebView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        _webView.backgroundColor = [UIColor clearColor];
        
        self.userInteractionEnabled = YES;
        
        // 网页缓存
         _urlCache = [[PSUrlCache alloc] initWithMemoryCapacity:MemoryCacheCap
                                                             diskCapacity:0
                                                                 diskPath:nil
                                                                cacheTime:0];
        [PSUrlCache setSharedURLCache:_urlCache];

        
        //网页视图
        _webView = [[UIWebView alloc] initWithFrame:self.bounds];
        _webView.delegate = self;
        _webView.userInteractionEnabled = YES;
        _webView.scalesPageToFit = YES; //自动对页面进行缩放以适应屏幕
        [self addSubview:_webView];
        
    }
    return self;
}

- (void)loadRequest:(NSString*)UrlString
{
    NSURL * url = [NSURL URLWithString:UrlString];
    NSURLRequest * request = [NSURLRequest requestWithURL:url];
    [_webView loadRequest:request];
}

- (void)cleanRequestCache
{
    [_urlCache removeAllCachedResponses];
}

#pragma mark - webview
- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    [MBProgressHUD hideHUDForView:self animated:YES];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    [MBProgressHUD hideHUDForView:self animated:YES];
}

- (void)webViewDidStartLoad:(UIWebView *)webView
{
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self animated:YES];
    hud.mode = MBProgressHUDModeIndeterminate;
    hud.labelText = @"Loading...";
}
@end
