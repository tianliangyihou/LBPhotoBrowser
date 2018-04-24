//
//  main.m
//  test
//
//  Created by dengweihao on 2017/3/14.
//  Copyright © 2017年 dengweihao. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"
#if DEBUG
#import <FBAllocationTracker/FBAllocationTrackerManager.h>
#import <FBRetainCycleDetector/FBRetainCycleDetector.h>

#endif

int main(int argc, char * argv[]) {
#if DEBUG
//    [FBAssociationManager hook];
//    [[FBAllocationTrackerManager sharedManager] startTrackingAllocations];
//    [[FBAllocationTrackerManager sharedManager] enableGenerations];
#endif
    @autoreleasepool {
        return UIApplicationMain(argc, argv, nil, NSStringFromClass([AppDelegate class]));
    }
}
