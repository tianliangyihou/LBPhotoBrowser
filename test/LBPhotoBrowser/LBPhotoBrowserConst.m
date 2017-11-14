//
//  LB_Header.m
//  
//
//  Created by dengweihao on 2017/8/2.
//
//

#ifndef __LBPhotoBrowserConst__M__
#define __LBPhotoBrowserConst__M__

#import <Foundation/Foundation.h>
#import "LBPhotoBrowserConst.h"
#import "LBPhotoBrowserManager.h"

inline BOOL isRemoteAddress(NSString * address) {
    return [address hasPrefix:@"http"];
}

NSString * const LBImageViewBeiginDragNot = @"LBImageViewBeiginDragNot";
NSString * const LBImageViewEndDragNot = @"LBImageViewEndDragNot";
NSString * const LBImageViewWillDismissNot = @"LBImageViewWillDismissNot";
NSString * const LBImageViewDidDismissNot = @"LBImageViewDidDismissNot";
NSString * const LBAddCoverImageViewNot = @"LBAddCoverImageViewNot";
NSString * const LBRemoveCoverImageViewNot = @"LBRemoveCoverImageViewNot";
#endif
