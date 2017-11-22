//
//  LBPhotoBrowserShowHelper.m
//  test
//
//  Created by dengweihao on 2017/11/13.
//  Copyright © 2017年 dengweihao. All rights reserved.
//

#import "LBPhotoBrowserShowHelper.h"
#import "LBPhotoBrowserManager.h"

static inline int lb_currentSelectImageViewIndex() {
     UICollectionView *currentCollectionView = [LBPhotoBrowserManager defaultManager].currentCollectionView;
     return (int)(currentCollectionView.contentOffset.x / currentCollectionView.width);

}

UIImageView * lb_lastMovedOrAnimationedImageView() {
    for (UIImageView *imageView in [LBPhotoBrowserManager defaultManager].imageViews) {
        if (imageView.hidden == YES) {
            return imageView;
        }
    }
    return nil;
}
@interface LBPhotoBrowserShowHelper ()

@end

@implementation LBPhotoBrowserShowHelper

- (NSMutableDictionary<NSString *,NSIndexPath *> *)showIndexPathDic {
    if (!_showIndexPathDic) {
        _showIndexPathDic = [NSMutableDictionary dictionary];
    }
    return _showIndexPathDic;
    
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _scrollPosition = LBScrollPositionHorizontallyCenter;
    }
    return self;
}

- (UIView *)lastShowView {
    if (self.lastShowIndex == -1) {
        return nil;
    }
    if (_showType == LBShowTypeCollectionView) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:self.lastShowIndex inSection:0];
        return [_collectioView cellForItemAtIndexPath:indexPath];
    }else {
        return _imageViews[self.lastShowIndex];
    }
    
}

- (UIView *)currentShowView {
    if (_showType == LBShowTypeCollectionView) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:self.currentShowIndex inSection:0];
        return [_collectioView cellForItemAtIndexPath:indexPath];
        ;
    }else {
        int lastIndex = lb_currentSelectImageViewIndex();
        return _imageViews[lastIndex];
    }
}


- (int)lastShowIndex {
    int index = -1;
    if (_showType == LBShowTypeCollectionView) {
        int count = (int)[self.collectioView numberOfItemsInSection:0];
        for (int i = 0; i < count; i++) {
            UICollectionViewCell *cell = [self.collectioView cellForItemAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0]];
            if (cell.hidden == YES) {
                index = i;
                break;
            }
        }
    }else {
        UIView *view = lb_lastMovedOrAnimationedImageView();
        index = (int)[self.imageViews indexOfObject:view];
    }
    return index;
}

- (int)currentShowIndex {
    if (self.showIndexPathDic && self.showIndexPathDic.count > 0) {
        int index = lb_currentSelectImageViewIndex();
        NSURL *url = [LBPhotoBrowserManager defaultManager].urls[index];
        for (NSString *urlString in self.showIndexPathDic.allKeys) {
            if ([urlString isEqualToString:url.absoluteString]) {
                return (int)self.showIndexPathDic[urlString].row;
            }
        }
    }
    return lb_currentSelectImageViewIndex();
}
- (int)phtotoBrowserCurrentShowIndex {
    return lb_currentSelectImageViewIndex();
}

- (void)setCollectioView:(UICollectionView *)collectioView {
    _collectioView = collectioView;
    _imageViews  = nil;
}

- (void)setImageViews:(LBImageViewsArray *)imageViews {
    _imageViews = imageViews;
    _collectioView = nil;
}

- (void)adjustCollectionViewContentOffsetWithIndexPath:(NSIndexPath *)indexPath {
    [self.collectioView scrollToItemAtIndexPath:indexPath atScrollPosition:(UICollectionViewScrollPosition)_scrollPosition animated:YES];
}

@end
