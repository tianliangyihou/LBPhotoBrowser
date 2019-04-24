//
//  AppDelegate.m
//  test
//
//  Created by dengweihao on 2017/3/14.
//  Copyright © 2017年 dengweihao. All rights reserved.
//

#import "AppDelegate.h"
#import <SDWebImage/SDWebImageManager.h>
#if DEBUG
#import <FBMemoryProfiler/FBMemoryProfiler.h>
#import <FBRetainCycleDetector/FBRetainCycleDetector.h>
#import <OOMDetector/OOMDetector.h>
#endif

@interface AppDelegate (){
#if DEBUG
    FBMemoryProfiler *_memoryProfiler;
#endif
}
@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    NSLog(@"%@",NSHomeDirectory());
#if DEBUG
//    _memoryProfiler = [FBMemoryProfiler new];
//    [_memoryProfiler enable];
#endif
//    [[OOMDetector getInstance] setupWithDefaultConfig];
    return YES;
}
@end
