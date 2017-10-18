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

#define LBPhotoBrowserLog(...) NSLog(__VA_ARGS__)

#else

#define LBPhotoBrowserLog(...)

#endif

#define  weak_self  __weak typeof(self) wself = self

#ifndef SCREEN_WIDTH

#define SCREEN_WIDTH [UIScreen mainScreen].bounds.size.width

#endif

#ifndef SCREEN_HEIGHT

#define SCREEN_HEIGHT [UIScreen mainScreen].bounds.size.height

#endif

#define IS_IPHONE [[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone

#define LB_DISMISS_DISTENCE SCREEN_HEIGHT


#define LB_BOTTOM_MARGIN_IPHONEX 34

#define LB_STUATUS_BAR_HEIGHT_IPHONEX 44

#define LB_IS_IPHONEX (SCREEN_HEIGHT == 812 && IS_IPHONE)

#define LB_BOTTOM_MARGIN (LB_IS_IPHONEX ? 34 : 0)

UIKIT_EXTERN int lb_currentSelectImageViewIndex();
UIKIT_EXTERN UIImageView * lb_lastMovedOrAnimationedImageView();
UIKIT_EXTERN BOOL isRemoteAddress(NSString * address);

UIKIT_EXTERN NSString * const LBImageViewBeiginDragNot;
UIKIT_EXTERN NSString * const LBImageViewEndDragNot;
UIKIT_EXTERN NSString * const LBImageViewWillDismissNot;
UIKIT_EXTERN NSString * const LBImageViewDidDismissNot;

UIKIT_EXTERN NSString * const LBAddCoverImageViewNot;
UIKIT_EXTERN NSString * const LBRemoveCoverImageViewNot;

#endif
