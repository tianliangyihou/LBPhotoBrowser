//
//  LB3DTouchVC.h
//  test
//
//  Created by dengweihao on 2017/9/25.
//  Copyright © 2017年 dengweihao. All rights reserved.
//


#import <UIKit/UIKit.h>
#import <objc/runtime.h>
#import "LBPhotoBrowserManager.h"
NS_ASSUME_NONNULL_BEGIN

@protocol LBTouchVCPreviewingDelegate <UIViewControllerPreviewingDelegate>
@required
- (void)lb_showPhotoBrowserFormImageView:(UIImageView *_Nullable)imageView;
@optional
- (void)lb_userDidSelectedPreviewTitle:(NSString *_Nullable)title;
- (UIPreviewActionStyle)lb_previewActionStyleForActionTitle:(NSString *_Nullable)title index:(NSInteger)index inTitles:(NSArray <NSString *>*_Nullable)titles;
- (UIImage *)lb_3DTouchPlaceholderImageForImageView:(UIImageView *)imageView;
@end

@interface LB3DTouchVC : UIViewController

@property (nonatomic , strong)NSMutableArray * _Nullable titles;

@property (nonatomic , weak)UIImageView * _Nullable imageView;

@property (nonatomic , weak)UIViewController<LBTouchVCPreviewingDelegate>* _Nullable delegate;

- (instancetype _Nullable )initWithDelegate:(UIViewController<LBTouchVCPreviewingDelegate>*_Nullable)delegate andWithPreviewActionTitles:(NSArray<NSString *> *_Nullable)titles;
@end



@interface UIViewController (LBExtension)

- (nullable UIViewController *)previewingContext:(id <UIViewControllerPreviewing>)previewingContext viewControllerForLocation:(CGPoint)location;
- (void)previewingContext:(id <UIViewControllerPreviewing>)previewingContext commitViewController:(UIViewController *_Nullable)viewControllerToCommit;
- (void)lb_registerForPreviewingWithDelegate:(id  <UIViewControllerPreviewingDelegate>)delegate sourceViews:(NSArray<UIView *> *)sourceViews previewActionTitles:(NSArray <NSString *>*)titles;

@end
NS_ASSUME_NONNULL_END

