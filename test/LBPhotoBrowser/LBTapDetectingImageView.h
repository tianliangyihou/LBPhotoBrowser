//
//  LBTapDetectingImageView.h
//  test
//
//  Created by dengweihao on 2017/3/16.
//  Copyright © 2017年 dengweihao. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LBPhotoBrowserConst.h"

@protocol LBTapDetectingImageViewDelegate;

@interface LBTapDetectingImageView : UIImageView

@property (nonatomic, weak) id <LBTapDetectingImageViewDelegate> tapDelegate;


@end


@protocol LBTapDetectingImageViewDelegate <NSObject>

@required

- (void)imageViewIsMovingWithImageView:(LBTapDetectingImageView *)imageView;
- (void)imageViewEndMoveImageView:(LBTapDetectingImageView *)imageView;
- (void)imageViewNeedRemoveFromSuperView;

@optional
- (void)imageView:(UIImageView *)imageView singleTapDetected:(UITouch *)touch;
- (void)imageView:(UIImageView *)imageView doubleTapDetected:(UITouch *)touch;

@end
