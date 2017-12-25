//
//  UIView+Frame.h
//  woaoappios
//
//  Created by jianghui yin on 14-10-8.
//  Copyright (c) 2014年 16816. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (LBFrame)

@property (nonatomic, assign) CGFloat top;
@property (nonatomic, assign) CGFloat bottom;
@property (nonatomic, assign) CGFloat right;
@property (nonatomic, assign) CGFloat left;
@property (nonatomic, assign) CGFloat width;
@property (nonatomic, assign) CGFloat height;

@property(nonatomic,assign)CGFloat centerX;
@property(nonatomic,assign)CGFloat centerY;
@end
