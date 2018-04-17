


//
//  MBProgressHUD+EX.m
//  test
//
//  Created by dengweihao on 2018/4/17.
//  Copyright © 2018年 dengweihao. All rights reserved.
//

#import "MBProgressHUD+EX.h"
#import <MBProgressHUD/MBProgressHUD.h>
@implementation MBProgressHUD (EX)

+ (void)showText:(NSString *)text toView:(UIView *)view
{
    if (view == nil) view = [UIApplication sharedApplication].keyWindow;
    // 快速显示一个提示信息
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:view animated:YES];
    hud.contentColor = [UIColor whiteColor];
    hud.bezelView.style = MBProgressHUDBackgroundStyleSolidColor;
    hud.bezelView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.7];
    hud.label.text = text;
    // 再设置模式
    hud.mode = MBProgressHUDModeCustomView;
    // 隐藏时候从父控件中移除
    hud.removeFromSuperViewOnHide = YES;
    // 1秒之后再消失
    [hud hideAnimated:YES afterDelay:1];
}

@end
