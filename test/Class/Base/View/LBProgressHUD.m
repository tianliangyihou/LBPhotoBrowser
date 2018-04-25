//
//  LBProgressHUD.m
//  test
//
//  Created by dengweihao on 2018/4/22.
//  Copyright © 2018年 dengweihao. All rights reserved.
//

#import "LBProgressHUD.h"

@implementation LBProgressHUD
+ (void)showTest:(NSString *)text {
    UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:nil message:text delegate:nil cancelButtonTitle:nil otherButtonTitles:nil, nil ];
    [alertView show];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [alertView dismissWithClickedButtonIndex:0 animated:YES];
    });
}
@end
