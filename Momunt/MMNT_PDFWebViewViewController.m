//
//  MMNT_PDFWebViewViewController.m
//  Momunt
//
//  Created by Masha Belyi on 11/29/14.
//  Copyright (c) 2014 Masha Belyi. All rights reserved.
//

#import "MMNT_PDFWebViewViewController.h"

@interface MMNT_PDFWebViewViewController ()

@end

@implementation MMNT_PDFWebViewViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)setUrl:(NSURL *)url{
    _url = url;
    [self loadRemotePdfFromUrl:url];
}

- (void)loadRemotePdfFromUrl:(NSURL *)url;
{

    CGRect rect = self.view.frame;
    CGSize screenSize = rect.size;
    
    UIWebView *myWebView = [[UIWebView alloc] initWithFrame:CGRectMake(0,0,screenSize.width,screenSize.height)];
    myWebView.autoresizesSubviews = YES;
    myWebView.autoresizingMask=(UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth);
    
    NSURLRequest *myRequest = [NSURLRequest requestWithURL:url];
    
    [myWebView loadRequest:myRequest];
    
    [self.view addSubview: myWebView];
    //    [myWebView release];
    
}

@end
