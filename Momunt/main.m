;//
//  main.m
//  Momunt
//
//  Created by Masha Belyi on 6/16/14.
//  Copyright (c) 2014 ___FULLUSERNAME___. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "MMNTAppDelegate.h"
#import "MMNTApplication.h"

int main(int argc, char * argv[])
{
    @autoreleasepool {
//        return UIApplicationMain(argc, argv, nil, NSStringFromClass([MMNTAppDelegate class]));
        return UIApplicationMain(argc, argv, NSStringFromClass([MMNTApplication class]), NSStringFromClass([MMNTAppDelegate class]));
    }
}
