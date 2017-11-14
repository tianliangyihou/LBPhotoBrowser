//
//  LBPhotoBrowseView.h
//  test
//
//  Created by dengweihao on 2017/8/2.
//  Copyright © 2017年 dengweihao. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LBPhotoBrowserView : UIView

- (void)showImageViewsWithURLs:(LBUrlsMutableArray *)urls fromImageView:(LBImageViewsArray *)imageViews andSelectedIndex:(int)index andImageViewSuperView:(UIView *)superView;

- (void)showImageWithURLArray:(NSArray *)urls fromCollectionView:(UICollectionView *)collectionView selectedIndex:(int)index;
@end

