//
//  LBPhotoBrowseConst.h
//  
//
//  Created by dengweihao on 2017/8/2.
//
//

#ifndef __LBPhotoBrowserConst__H__
#define __LBPhotoBrowserConst__H__

#import <Foundation/Foundation.h>
#import "UIView+Frame.h"

typedef NSMutableArray<NSURL *> LBUrlsMutableArray;
typedef NSMutableArray <UIImageView *> LBImageViewsArray;

#ifdef DEBUG

#define LBPhotoBrowseLog(...) NSLog(__VA_ARGS__)

#else

#define LBPhotoBrowseLog(...)

#endif

#define  weak_self  __weak typeof(self) wself = self

#ifndef SCREEN_WIDTH

#define SCREEN_WIDTH [UIScreen mainScreen].bounds.size.width

#endif

#ifndef SCREEN_HEIGHT

#define SCREEN_HEIGHT [UIScreen mainScreen].bounds.size.height

#endif

#define LB_DISMISS_DISTENCE SCREEN_HEIGHT

#define LBcurrentSelectImageViewIndex \
static inline int currentSelectImageViewIndex() { \
    UICollectionView *currentCollectionView = [LBPhotoBrowserManager defaultManager].currentCollectionView;\
    return (int)(currentCollectionView.contentOffset.x / SCREEN_WIDTH);\
}\

#define LBLastMovedOrAnimationedImageView  \
static UIImageView* lastMovedOrAnimationedImageView() {\
    for (UIImageView *imageView in [LBPhotoBrowserManager defaultManager].imageViews) {\
        if (imageView.hidden == YES) {\
            return imageView;\
        }\
    }\
    return nil;\
}\

#define LB_CurrentSelectImageViewIndex LBcurrentSelectImageViewIndex
#define LB_LastMovedOrAnimationedImageView LBLastMovedOrAnimationedImageView


UIKIT_EXTERN NSString * const LBImageViewBeiginDragNot;
UIKIT_EXTERN NSString * const LBImageViewEndDragNot;
UIKIT_EXTERN NSString * const LBImageViewWillDismissNot;
UIKIT_EXTERN NSString * const LBImageViewDidDismissNot;


UIKIT_EXTERN NSString * const LBAddCoverImageViewNot;
UIKIT_EXTERN NSString * const LBRemoveCoverImageViewNot;

#endif
