//
//  LLBLoadingView.h
//  loadingView
//
//  Created by llb on 16/10/5.
//  Copyright © 2016年 llb. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LBLoadingView : UIView

+ (UILabel *)showText:(NSString *)text toView:(UIView *)superView dismissAfterSecond:(NSTimeInterval)second;

@end
