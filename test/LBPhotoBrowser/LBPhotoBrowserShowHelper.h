//
//  LBPhotoBrowserShowHelper.h
//  test
//
//  Created by dengweihao on 2017/11/13.
//  Copyright © 2017年 dengweihao. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LBPhotoBrowserConst.h"

typedef NS_ENUM(NSUInteger, LBShowType) {
    LBShowTypeViews = 0,
    LBShowTypeCollectionView = 1,
};

typedef NS_ENUM(NSUInteger, LBScrollPosition) {
    LBScrollPositionLeft = UICollectionViewScrollPositionLeft,
    LBScrollPositionHorizontallyCenter = UICollectionViewScrollPositionCenteredHorizontally,
    LBScrollPositionRight = UICollectionViewScrollPositionRight
};

@interface LBPhotoBrowserShowHelper : NSObject

@property (nonatomic , weak)UIView *lastShowView;

@property (nonatomic , weak)UIView *currentShowView;

@property (nonatomic , assign)LBShowType showType;

@property (nonatomic , assign)LBScrollPosition scrollPosition;

@property (nonatomic , weak)UICollectionView *collectioView;

@property (nonatomic , weak)NSArray *imageViews;

@property (nonatomic , strong)NSMutableDictionary <NSString *, NSIndexPath *> *showIndexPathDic;

@property (nonatomic , assign)int lastShowIndex;

@property (nonatomic , assign)int currentShowIndex;



- (void)adjustCollectionViewContentOffsetWithIndexPath:(NSIndexPath *)indexPath;

@end
