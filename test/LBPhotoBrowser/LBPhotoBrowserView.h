//
//  LBPhotoBrowseView.h
//  test
//
//  Created by dengweihao on 2017/8/2.
//  Copyright © 2017年 dengweihao. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LBPhotoBrowserView : UIWindow

@property (nonatomic , weak)UIPageControl *pageControl;

- (void)showImageViewsWithURLs:(LBUrlsMutableArray *)urls andSelectedIndex:(int)index;

- (void)showImageViewsWithImages:(LBImagesMutableArray *)images andSeletedIndex:(int)index;

@end


@interface LBScrollViewStatusModel : NSObject

@property (nonatomic , strong)NSNumber *scale;
@property (nonatomic , assign)CGPoint contentOffset;

@property (nonatomic , strong)UIImage *currentPageImage;
@property (nonatomic , strong)NSURL *url;

@property (nonatomic , strong)id opreation;

@property (nonatomic , assign)BOOL isShowing;
@property (nonatomic , assign)BOOL showPopAnimation;
@property (nonatomic , assign)int index;

@property (nonatomic , copy)void (^loadImageCompletedBlock)(LBScrollViewStatusModel *loadModel,UIImage *image, NSData *data, NSError *  error, BOOL finished, NSURL *imageURL);

- (void)loadImageWithCompletedBlock:(void (^)(LBScrollViewStatusModel *loadModel,UIImage *image, NSData *data, NSError *  error, BOOL finished, NSURL *imageURL))completedBlock;
@end
