//
//  LBTapDetectingImageView.m
//  test
//
//  Created by dengweihao on 2017/3/16.
//  Copyright © 2017年 dengweihao. All rights reserved.
//

#import "LBPhotoBrowserManager.h"
#import "LBOptionView.h"
#import "LBTapDetectingImageView.h"
#import "LBZoomScrollView.h"

@interface LBTapDetectingImageView ()


@property (nonatomic , weak)UIView *optionView;

@end

@implementation LBTapDetectingImageView

- (UIView *)optionView {
    if (_optionView) return _optionView;
    LBPhotoBrowserManager *mgr = [LBPhotoBrowserManager defaultManager];
    if (mgr.longPressCustomViewBlock) {
        UIView *optionView = mgr.longPressCustomViewBlock(self.image,[NSIndexPath indexPathForRow:mgr.currentPage inSection:0]);
        [[UIApplication sharedApplication].keyWindow addSubview:optionView];
        _optionView = optionView;
    }else {
        LBZoomScrollView *scrollView =  (LBZoomScrollView *)self.superview;
        _optionView = [LBOptionView showOptionViewWithCurrentCellImage:scrollView.model.currentPageImage];
    }
    return _optionView;
}

- (id)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
        self.userInteractionEnabled = YES;
        self.contentMode = UIViewContentModeScaleAspectFill;
        self.clipsToBounds = YES;
        UILongPressGestureRecognizer *ges = [[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(longPressAction)];
        [self addGestureRecognizer:ges];
    }
    return self;
}

- (void)longPressAction {
    LBPhotoBrowserManager *mgr = [LBPhotoBrowserManager defaultManager];
    if (!mgr.currentTitles || mgr.currentTitles.count == 0) {
        return;
    }
    [self optionView];
}


@end
