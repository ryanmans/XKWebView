//
//  PSWebViewController.m
//  PSWebView
//
//  Created by Ryan_Man on 16/6/27.
//  Copyright © 2016年 Ryan_Man. All rights reserved.
//

#import "PSWebViewController.h"

#import "PSWebView.h"

@interface PSWebViewController ()
@property (nonatomic,strong)PSWebView * webView;
@end

@implementation PSWebViewController
- (PSWebView*)webView
{
    if (!_webView)
    {
        _webView = [[PSWebView alloc] initWithFrame:self.view.bounds];
    }
    return _webView;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = @"网页数据缓存";
    
    [self.view addSubview:self.webView];
    
    //加载网页
    [self.webView loadRequest:@"http://www.apple.com/cn/mac/"];
    
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    
    //清空网页缓存数据
    [self.webView cleanRequestCache];
    
}
@end
