//
//  WIViewController.m
//  WebInvoker
//
//  Created by jindw on 14-8-17.
//  Copyright (c) 2014年 ___webview___. All rights reserved.
//

#import "WIViewController.h"
#import "XIdeaWebInterface.h"

@interface WIViewController ()

@end

@implementation WIViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    [XIdeaWebInterface.instance registor:@"object" object:self];
    
    self.webView  = [[UIWebView alloc] initWithFrame:CGRectMake(0, 20, 320, 460)];
    [self.view addSubview: self.webView];
    NSURL *url = [ [[NSBundle mainBundle] bundleURL] URLByAppendingPathComponent:@"test.html"];
	[self.webView loadRequest:[NSURLRequest requestWithURL:url]];
}
- (NSString *) method:(NSArray*)arguments{
    return [NSString stringWithFormat :@"arguments:%@" ,arguments];
}
- (NSString *) method:(NSNumber*)a p1:(NSString*) p1{
    return [NSString stringWithFormat :@"arguments:%d,%@" ,[a intValue],p1];
}

@end
