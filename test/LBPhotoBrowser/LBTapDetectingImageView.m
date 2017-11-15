//
//  LBTapDetectingImageView.m
//  test
//
//  Created by dengweihao on 2017/3/16.
//  Copyright © 2017年 dengweihao. All rights reserved.
//

#import "UIView+Frame.h"
#import "LBPhotoBrowserManager.h"
#import "LBOptionView.h"
#import "LBTapDetectingImageView.h"

@interface LBTapDetectingImageView ()

@property (nonatomic , assign)CGPoint lastPoint;
@property (nonatomic , assign)BOOL movable;
@property (nonatomic , assign)CGPoint originalPoint;
@property (nonatomic , assign)CGAffineTransform originalTransform;
@property (nonatomic , assign)CGRect originalFrame ;
@property (nonatomic , assign)CGPoint originalCenter;

@property (nonatomic , weak)UIView *optionView;

@end

@implementation LBTapDetectingImageView

- (NSIndexPath *)currentIndexPath {
    LBPhotoBrowserManager *mgr = [LBPhotoBrowserManager defaultManager];
    NSURL *currentUrl = [self.superview valueForKeyPath:@"url"];
    NSIndexPath *indexPath = nil;
    for (int i = 0; i < mgr.urls.count; i ++) {
        NSURL *url = mgr.urls[i];
        if (url == currentUrl) {
            indexPath = [NSIndexPath indexPathForRow:i inSection:0];
            break;
        }
    }
    return indexPath;
}

- (UIView *)optionView {
    if (_optionView) return _optionView;
    LBPhotoBrowserManager *mgr = [LBPhotoBrowserManager defaultManager];
    if (mgr.longPressCustomViewBlock) {
        UIView *optionView = mgr.longPressCustomViewBlock(self.image,[self currentIndexPath]);
        [[UIApplication sharedApplication].keyWindow addSubview:optionView];
        _optionView = optionView;
    }else {
    _optionView = [LBOptionView showOptionViewWithCurrentCellImage:self.image];
    }
    return _optionView;
}


- (id)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
        self.userInteractionEnabled = YES;
        UILongPressGestureRecognizer *ges = [[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(longPressAction)];
        [self addGestureRecognizer:ges];
    }
    return self;
}

- (void)longPressAction {
    [self optionView];
}


- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [[NSNotificationCenter defaultCenter] postNotificationName:LBImageViewBeiginDragNot object:nil];
    UITouch *touch = [touches anyObject];
    CGPoint point = [touch locationInView:[UIApplication sharedApplication].keyWindow];
    self.originalCenter = self.center;
    self.originalTransform = self.transform;
    self.originalFrame = self.frame;
    self.originalPoint = point;
    self.lastPoint = point;
}


- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    CGPoint point = [touch locationInView:[UIApplication sharedApplication].keyWindow];
    if (_lastPoint.y >= point.y && _movable == NO) return;
    
    CGFloat deviationX = point.x - _lastPoint.x;
    CGFloat deviationY = point.y - _lastPoint.y;
    _lastPoint = point;
    _movable = YES; // 控制是否可以向上移动
    if ([self.superview isKindOfClass:[UIScrollView class]]) {
        [(UIScrollView *)self.superview  setScrollEnabled:NO];
    }
    
    self.center = CGPointMake(self.center.x + deviationX, self.center.y + deviationY);

    CGFloat currentDeviationFromBegin = point.y - self.originalPoint.y;
    if (currentDeviationFromBegin > (LB_DISMISS_DISTENCE - 40)) {
        currentDeviationFromBegin = (LB_DISMISS_DISTENCE - 40);
    }
    if (currentDeviationFromBegin <= 0) {
        currentDeviationFromBegin = 0;
    }
    if ([_tapDelegate respondsToSelector:@selector(imageViewIsMovingWithImageView:)]) {
        [_tapDelegate imageViewIsMovingWithImageView:self];
    }
    CGFloat ration = 1 - currentDeviationFromBegin/LB_DISMISS_DISTENCE;
    self.transform = CGAffineTransformScale(self.originalTransform, ration, ration);

    [LBPhotoBrowserManager defaultManager].currentCollectionView.superview.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:(LB_DISMISS_DISTENCE-currentDeviationFromBegin)/(LB_DISMISS_DISTENCE - 40)];
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    
    [[NSNotificationCenter defaultCenter] postNotificationName:LBImageViewEndDragNot object:nil];
    [self handlerTouchEvent:event andTouches:touches];
    // 初始化
    _lastPoint = CGPointZero;
    if (_movable == NO) return;
    
    if (self.width / self.originalFrame.size.width < 0.6) {
        if ([_tapDelegate respondsToSelector:@selector(imageViewNeedRemoveFromSuperView)]) {
            [_tapDelegate imageViewNeedRemoveFromSuperView];
        }
        return;
    }
    weak_self;
    [UIView animateWithDuration:0.25 animations:^{
        
        wself.transform = wself.originalTransform;
        wself.frame = wself.originalFrame;
        wself.center = wself.originalCenter;
        [LBPhotoBrowserManager defaultManager].currentCollectionView.superview.backgroundColor = [UIColor blackColor];
        
    }completion:^(BOOL finished) {
        UIScrollView *sc =(UIScrollView *)wself.superview;
        if ([sc isKindOfClass:[UIScrollView class]]) {
            [sc  setScrollEnabled:YES];
        }
        if ([wself.tapDelegate respondsToSelector:@selector(imageViewEndMoveImageView:)]) {
            [wself.tapDelegate imageViewEndMoveImageView:wself];
        }
        wself.movable = NO;
    }];

}

- (void)handlerTouchEvent:(UIEvent *)event andTouches:(NSSet *)touches {
    
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    UITouch *touch = [touches anyObject];
    if (touch.tapCount == 1) {
        [self performSelector:@selector(handleSingleTap:) withObject:touch afterDelay:0.3];
    }else if(touch.tapCount == 2){
        [self handleDoubleTap:touch];
    }
    
}

- (void)handleSingleTap:(UITouch *)touch {
    
    if ([_tapDelegate respondsToSelector:@selector(imageView:singleTapDetected:)])
        [_tapDelegate imageView:self singleTapDetected:touch];
}

- (void)handleDoubleTap:(UITouch *)touch {
    
    if ([_tapDelegate respondsToSelector:@selector(imageView:doubleTapDetected:)])
        [_tapDelegate imageView:self doubleTapDetected:touch];
}

@end
