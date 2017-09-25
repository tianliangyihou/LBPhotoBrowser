//
//  LB3DTouchVC.m
//  test
//
//  Created by dengweihao on 2017/9/25.
//  Copyright © 2017年 dengweihao. All rights reserved.
//

#import "LB3DTouchVC.h"

@interface LB3DTouchVC ()

@property (nonatomic , weak)UIImageView *showImageView;

@property (nonatomic , assign)BOOL showRemoveObserver;

@end

@implementation LB3DTouchVC

- (void)dealloc {
    @try {
        if (_showRemoveObserver) {
            [_imageView removeObserver:self forKeyPath:@"image"];
        }
    } @catch (NSException *exception) {
        LBPhotoBrowserLog(@"%@",exception);
    }
}

- (UIImageView *)showImageView {
    if (!_showImageView) {
        UIImageView *showImageView = [[UIImageView alloc]init];
        [self.view addSubview:showImageView];
        _showImageView = showImageView;
    }
    return _showImageView;
}

- (instancetype)initWithDelegate:(UIViewController<LBTouchVCPreviewingDelegate> *)delegate andWithPreviewActionTitles:(NSArray<NSString *> *)titles{
    if ([super init]) {
        LB3DTouchVC *touchVC = [super init];
        touchVC.delegate = delegate;
        [touchVC.titles addObjectsFromArray:titles];
        return touchVC;
    }
    return nil;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.view.backgroundColor = [UIColor clearColor];
        self.view.userInteractionEnabled = NO;
    }
    return self;
}

- (NSMutableArray *)titles {
    if (!_titles) {
        _titles = [[NSMutableArray alloc]init];
    }
    return _titles;
}

- (void)setImageView:(UIImageView *)imageView {
    _imageView = imageView;
    UIImage *sourceImage = nil;
    if (imageView.image) {
        sourceImage =  imageView.image;
    }else {
        
        sourceImage = [UIImage imageNamed:@"LBLoading.png"];
        if (self.delegate && [self.delegate respondsToSelector:@selector(lb_3DTouchPlaceholderImageForImageView:)]) {
            sourceImage = [self.delegate lb_3DTouchPlaceholderImageForImageView:imageView];
        }
        [_imageView addObserver:self forKeyPath:@"image" options:NSKeyValueObservingOptionNew context:nil];
        _showRemoveObserver = YES;
    }
    
    [self adjustPreviewingWithImage:sourceImage];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    if ([keyPath isEqualToString:@"image"]) {
        UIImage *newImage = change[NSKeyValueChangeNewKey];
        [self adjustPreviewingWithImage:newImage];
    }
}

- (void)adjustPreviewingWithImage:(UIImage *)image {
    self.showImageView.image = image;
    CGSize newSize = [self newSizeForImageViewWithImage:image];
    self.preferredContentSize = newSize;
    self.showImageView.frame = CGRectMake(0, 0, newSize.width, newSize.height);
}


- (UIPreviewAction *)previewActionForTitle:(NSString *)title style:(UIPreviewActionStyle)style {
    weak_self;
    return [UIPreviewAction actionWithTitle:title style:style handler:^(UIPreviewAction * _Nonnull action, UIViewController * _Nonnull previewViewController) {
        if (wself.delegate && [wself.delegate respondsToSelector:@selector(lb_userDidSelectedPreviewTitle:)]) {
            [wself.delegate lb_userDidSelectedPreviewTitle:title];
        }
    }];
}
- (NSArray<id<UIPreviewActionItem>> *)previewActionItems {
    NSMutableArray *previewActions = [NSMutableArray array];
    for (int i = 0 ; i < self.titles.count; i++) {
        UIPreviewAction *action = nil;
        if (_delegate && [_delegate respondsToSelector:@selector(lb_previewActionStyleForActionTitle:index:inTitles:)]) {
            UIPreviewActionStyle style = [_delegate lb_previewActionStyleForActionTitle:self.titles[i] index:i inTitles:self.titles.copy];
            action = [self previewActionForTitle:self.titles[i] style:style];
        }else{
            action = [self previewActionForTitle:self.titles[i] style:UIPreviewActionStyleDefault];
            
        }
        [previewActions addObject:action];
    }
    return  previewActions;
}

- (CGSize)newSizeForImageViewWithImage:(UIImage *)image {
    float width = 0;
    float height = 0;
    float maxWidth = SCREEN_WIDTH;
    float maxHeight = SCREEN_HEIGHT;
    
    float scale=(float)image.size.width/image.size.height;
    float newScale=(float)maxWidth/maxHeight;
    if (scale >= newScale) {
        width = (float)image.size.width/maxWidth;
        height = (float)image.size.height/width;
        width = maxWidth;
    }else
    {
        height = (float)image.size.height/maxHeight;
        width = (float)image.size.width/height;
        height = maxHeight;
    }
    return CGSizeMake(width,height);
}

@end

@interface  UIViewController()

@property (nonatomic, setter=lb_setTitles:,getter=lb_titles)NSArray * _Nullable titles;

@end

@implementation UIViewController (LBExtension)

- (NSArray *)lb_titles {
    return objc_getAssociatedObject(self, @selector(lb_titles));
}

- (void)lb_setTitles:(NSArray *)titles {
    objc_setAssociatedObject(self, @selector(lb_titles), titles, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
- (nullable UIViewController *)previewingContext:(id <UIViewControllerPreviewing>)previewingContext viewControllerForLocation:(CGPoint)location {
#pragma clang diagnostic push
#pragma clang diagnostic ignored"-Wincompatible-pointer-types"
    LB3DTouchVC *touchVC = [[LB3DTouchVC alloc]initWithDelegate:self andWithPreviewActionTitles:self.lb_titles];
#pragma clang diagnostic pop
    touchVC.imageView = (UIImageView *)previewingContext.sourceView;
    return touchVC;
}
- (void)previewingContext:(id <UIViewControllerPreviewing>)previewingContext commitViewController:(UIViewController *)viewControllerToCommit {
    weak_self;
    UIImageView *imageView = (UIImageView *)previewingContext.sourceView;
    [LBPhotoBrowserManager defaultManager].showBrowserWithAnimation = NO;
    [wself performSelector:@selector(lb_showPhotoBrowserFormImageView:) withObject:imageView afterDelay:0];
}
- (void)lb_registerForPreviewingWithDelegate:(id<UIViewControllerPreviewingDelegate>)delegate sourceViews:(NSArray<UIView *> *)sourceViews previewActionTitles:(NSArray<NSString *> *)titles {
    if (self.traitCollection.forceTouchCapability == UIForceTouchCapabilityAvailable) {
        NSAssert([self conformsToProtocol:@protocol(LBTouchVCPreviewingDelegate)], @"如需使用3Dtouch,请遵守<LBTouchVCPreviewingDelegate>");
        for (UIView *view in sourceViews) {
            [self registerForPreviewingWithDelegate:delegate sourceView:view];
        }
        [self lb_setTitles:titles];
    }else {
        LBPhotoBrowserLog(@"该手机暂不支持3DTouch或者3DTouch功能关闭");
    }
    
}

@end


