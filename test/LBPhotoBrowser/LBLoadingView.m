//
//  LLBLoadingView.m
//  loadingView
//
//  Created by llb on 16/10/5.
//  Copyright © 2016年 llb. All rights reserved.
//

#import "LBLoadingView.h"
#import "LBPhotoBrowserConst.h"

static CGFloat second = 0.02;
static CGFloat lineWidth = 5;

@interface LBLoadingView ()

@property (nonatomic , weak)NSTimer *timer;

@end


@implementation LBLoadingView

- (void)dealloc {
    if (self.timer) {
        [self.timer invalidate];
        self.timer = nil;
    }
}

+ (UILabel *)showText:(NSString *)text toView:(UIView *)superView dismissAfterSecond:(NSTimeInterval)second {
    
    if (!superView) {
        superView = [UIApplication sharedApplication].keyWindow;
    }
    
    UILabel *textLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0,SCREEN_WIDTH - 40, 40)];
    textLabel.text = text;
    textLabel.textAlignment = NSTextAlignmentCenter;
    textLabel.center = superView.center;
    textLabel.textColor = [UIColor whiteColor];
    textLabel.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.8];
    [superView addSubview:textLabel];
    
    if (second < 0) {
        return textLabel;
    }
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(second * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [UIView animateWithDuration:0.25 animations:^{
            textLabel.alpha = 0.2;
        }completion:^(BOOL finished) {
            [textLabel removeFromSuperview];
        }];
    });
    return textLabel;
}

- (NSTimer *)timer {
    if (!_timer) {
        _timer =  [NSTimer scheduledTimerWithTimeInterval:second target:self selector:@selector(timerView) userInfo:nil repeats:YES];
        [[NSRunLoop currentRunLoop] addTimer:_timer forMode:NSRunLoopCommonModes];
    }
    return _timer;
}


- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        CGFloat rabius1 = frame.size.width/2;
        CGFloat starAgle1 = 0;
        CGFloat endAngle1 = 2 * M_PI;
        CGPoint point1 = CGPointMake(frame.size.width/2,frame.size.width/2);
        UIBezierPath *path1 = [UIBezierPath bezierPathWithArcCenter:point1 radius:rabius1 startAngle:starAgle1 endAngle:endAngle1 clockwise:YES];
        
        CAShapeLayer *layer1 = [[CAShapeLayer alloc]init];
        layer1.path = path1.CGPath;
        layer1.fillColor = [UIColor clearColor].CGColor;
        // #000000黑色 #ffffff 白色
        layer1.strokeColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5].CGColor;
        layer1.lineWidth = lineWidth;
        [self.layer addSublayer:layer1];
        
        
        CGFloat rabius = frame.size.width/2 ;
        CGFloat starAngle = 2 * M_PI * 0.85;
        CGPoint point = CGPointMake(frame.size.width/2, frame.size.width/2);
        CGFloat endAngle = 2 * M_PI;
        
        UIBezierPath *path = [UIBezierPath bezierPathWithArcCenter:point radius:rabius startAngle:starAngle endAngle:endAngle clockwise:YES];
        CAShapeLayer *layer = [[CAShapeLayer alloc]init];
        layer.path = path.CGPath;
        layer.lineCap = kCALineCapRound;
        
        layer.strokeColor = [UIColor whiteColor].CGColor;
        layer.fillColor = [UIColor clearColor].CGColor;
        layer.lineWidth = lineWidth;
        [self.layer addSublayer:layer];
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

- (void)willMoveToSuperview:(UIView *)newSuperview {
    [super willMoveToSuperview:newSuperview];
    [self timer];
}

- (void)timerView{
    self.transform = CGAffineTransformRotate(self.transform, 0.2);
}

- (void)removeFromSuperview {
    [super removeFromSuperview];
    [self.timer invalidate];
    self.timer = nil;
}

@end
