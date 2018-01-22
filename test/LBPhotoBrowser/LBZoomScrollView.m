//
//  LBZoomScrollView.m
//  test
//
//  Created by dengweihao on 2017/3/15.
//  Copyright © 2017年 dengweihao. All rights reserved.
//

#import "LBPhotoBrowserConst.h"
#import "LBPhotoBrowserManager.h"
#import "LBZoomScrollView.h"
#import "LBLoadingView.h"
#import "LBTapDetectingImageView.h"
#import "LBPhotoBrowserView.h"
#import "UIImage+LBDecoder.h"

#if __has_include(<SDWebImage/SDWebImageManager.h>)
#import <SDWebImage/SDWebImageManager.h>
#import <SDWebImage/UIImageView+WebCache.h>
#import <SDWebImage/SDImageCacheConfig.h>
#import <SDWebImage/UIImage+MultiFormat.h>
#else
#import "SDWebImageManager.h"
#import "UIImageView+WebCache.h"
#import "SDImageCacheConfig.h"
#import "UIImage+MultiFormat.h"
#endif

static inline CGRect moveSizeToCenter(CGSize size) {
    return CGRectMake(SCREEN_WIDTH /2.0 - size.width / 2.0, SCREEN_HEIGHT /2.0 - size.height / 2.0, size.width, size.height);
}

static CGFloat scrollViewMinZoomScale = 1.0;
static CGFloat scrollViewMaxZoomScale = 3.0;

@interface LBZoomScrollView ()<UIScrollViewDelegate,UIGestureRecognizerDelegate>

@property (nonatomic , weak)LBLoadingView *loadingView;
@property (nonatomic , assign)CGSize imageSize;
@property (nonatomic , assign)CGRect oldFrame;

@end

@implementation LBZoomScrollView


#pragma mark - getter

- (LBTapDetectingImageView *)imageView {
    if (!_imageView) {
        LBTapDetectingImageView *imageView  = [[LBTapDetectingImageView alloc]init];
        [self addSubview:imageView];
        _imageView = imageView;
    }
    return _imageView;
}

- (LBLoadingView *)loadingView {
    if (!_loadingView) {
        LBLoadingView *loadingView = [[LBLoadingView alloc]initWithFrame:CGRectMake(0, 0, 40, 40)];
        loadingView.frame = moveSizeToCenter(loadingView.frame.size);
        [self addSubview:loadingView];
        _loadingView = loadingView;
    }
    return _loadingView;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        self.delegate = self;
        self.alwaysBounceVertical = YES;
        self.showsHorizontalScrollIndicator = NO;
        self.showsVerticalScrollIndicator = NO;
        self.decelerationRate = UIScrollViewDecelerationRateFast;
        self.frame = CGRectMake(10, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height);
        self.panGestureRecognizer.delegate = self;
        self.minimumZoomScale = scrollViewMinZoomScale;
        [self imageView];
    }
    return self;
}

- (UIImage *)getPlaceholdImageForModel:(LBScrollViewStatusModel *)model {
    LBPhotoBrowserManager *mgr = [LBPhotoBrowserManager defaultManager];
    UIImage *placeholdImage = nil;
    if (mgr.placeholdImageCallBackBlock) {
        placeholdImage =  mgr.placeholdImageCallBackBlock([NSIndexPath indexPathForItem:model.index inSection:0]);
        if (!placeholdImage) {
            placeholdImage =[UIImage imageNamed:@"LBLoading.png"];
        }
    }else {
        placeholdImage =[UIImage imageNamed:@"LBLoading.png"];
    }
    return placeholdImage;
}

- (void)setModel:(LBScrollViewStatusModel *)model {
    _model = model;
    weak_self;
    [self removePreviousFadeAnimationForLayer:self.imageView.layer];
    LBPhotoBrowserManager *mgr = [LBPhotoBrowserManager defaultManager];
    if (!model.currentPageImage) {
        [self loadingView];
        wself.maximumZoomScale = scrollViewMinZoomScale;
        CGSize size = mgr.placeholdImageSizeBlock ? mgr.placeholdImageSizeBlock([self getPlaceholdImageForModel:model],[NSIndexPath indexPathForItem:model.index inSection:0]) : CGSizeZero;
        if (!CGSizeEqualToSize(size, CGSizeZero)) {
            self.imageView.frame = moveSizeToCenter(size);
        }else {
            [self resetScrollViewStatusWithImage:[self getPlaceholdImageForModel:model]];
        }
        self.imageView.image = [self getPlaceholdImageForModel:model];
        [model loadImageWithCompletedBlock:^(LBScrollViewStatusModel *loadModel, UIImage *image, NSData *data, NSError *error, BOOL finished, NSURL *imageURL) {
            [wself.loadingView removeFromSuperview];
            wself.maximumZoomScale = scrollViewMaxZoomScale;
            if (error) {
                image = mgr.errorImage;
                LBPhotoBrowserLog(@"%@",error);
            }
            model.currentPageImage  = image;
            if (image.images.count > 0) {
                model.currentPageImage = mgr.lowGifMemory ? image : [UIImage sdOverdue_animatedGIFWithData:data];
            }
            // 下载完成之后 只有当前cell正在展示 --> 刷新
            NSArray *cells = [mgr.currentCollectionView visibleCells];
            for (id obj in cells) {
                LBScrollViewStatusModel *visibleModel = [obj valueForKeyPath:@"model"];
                if (model.index == visibleModel.index) {
                    [wself reloadCellDataWithModel:model andImage:image andImageData:data];
                }
            }
        }];
    }else {
        if (_loadingView) {
            [_loadingView removeFromSuperview];
        }
        [self resetScrollViewStatusWithImage:model.currentPageImage];
        /**
          when lowGifMemory = NO,if not clear this image ,gif image may have some thing wrong
         */
        self.imageView.image = nil;
        self.imageView.image = model.currentPageImage;
        self.maximumZoomScale = scrollViewMaxZoomScale;
    }
    self.zoomScale = model.scale.floatValue;
    self.contentOffset = model.contentOffset;
}

- (void)reloadCellDataWithModel:(LBScrollViewStatusModel *)model andImage:(UIImage *)image andImageData:(NSData *)data{
    LBPhotoBrowserManager *mgr = [LBPhotoBrowserManager defaultManager];
    self.imageView.image = model.currentPageImage;
    [self resetScrollViewStatusWithImage:model.currentPageImage];
    CGSize size = mgr.placeholdImageSizeBlock ? mgr.placeholdImageSizeBlock([self getPlaceholdImageForModel:model], [NSIndexPath indexPathForItem:model.index inSection:0]) : CGSizeZero;
    if (!CGSizeEqualToSize(size, CGSizeZero)) {
        CGRect imageViewFrame = self.imageView.frame;
        self.imageView.frame = moveSizeToCenter(size);
        [UIView animateWithDuration:0.25 animations:^{
            self.imageView.frame = imageViewFrame;
        }];
    }else {
        [self addFadeAnimationWithDuration:0.25 curve:UIViewAnimationCurveLinear ForLayer:self.imageView.layer];
    }
    /**
     当gif下载完成 并且正在当前的展示状态的时候
     由于SDWebImage异步下载图片 导致可能图片没有完全写入沙盒 故:
     */
    if (image.images.count > 0 && model.index == mgr.currentPage && mgr.lowGifMemory) {
        [mgr setValue:data forKey:@"spareData"];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.15 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [[NSNotificationCenter defaultCenter] postNotificationName:LBGifImageDownloadFinishedNot object:nil];
        });
    }
}


- (void)startPopAnimationWithModel:(LBScrollViewStatusModel *)model completionBlock:(void (^)(void))completion {
    UIImage *currentImage = model.currentPageImage;
    _model = model;
    if (!currentImage) {
        currentImage = [self getPlaceholdImageForModel:model];
    }
    [self showPopAnimationWithImage:currentImage WithCompletionBlock:completion];
}

- (void)showPopAnimationWithImage:(UIImage *)image WithCompletionBlock:(void (^)(void))completion {
    weak_self;
    LBPhotoBrowserManager *mgr = [LBPhotoBrowserManager defaultManager];
//    UIView *animationView = mgr.imageViews[mgr.currentPage];
    CGRect animationViewFrame = [mgr.frames[mgr.currentPage]  CGRectValue];
    CGRect rect = [mgr.imageViewSuperView convertRect: animationViewFrame toView:[UIApplication sharedApplication].keyWindow];
    self.oldFrame = rect;
    CGRect photoImageViewFrame;
    CGSize size = mgr.placeholdImageSizeBlock ? mgr.placeholdImageSizeBlock(image, [NSIndexPath indexPathForItem:self.model.index inSection:0]) : CGSizeZero;
    if (!CGSizeEqualToSize(size, CGSizeZero) && !self.model.currentPageImage) {
        photoImageViewFrame = moveSizeToCenter(size);
    }else {
        [self resetScrollViewStatusWithImage:image];        
        photoImageViewFrame = self.imageView.frame;
    }
    self.imageViewIsMoving = YES;
    self.imageView.frame = self.oldFrame;
    [UIView animateWithDuration:0.25 delay:0 options:UIViewAnimationOptionBeginFromCurrentState|UIViewAnimationOptionCurveEaseInOut animations:^{
        wself.imageView.frame = photoImageViewFrame;
    }completion:^(BOOL finished) {
        wself.imageViewIsMoving = NO;
        [wself layoutSubviews];// sometime need layout
        if (completion) {
            completion();
        }
    }];
    // if not clear this image ,gif image may have some thing wrong
    self.imageView.image = nil;
    self.imageView.image = image;
    [self setNeedsLayout];
}


- (void)resetScrollViewStatusWithImage:(UIImage *)image {
    self.zoomScale = scrollViewMinZoomScale;
    self.imageView.frame = CGRectMake(0, 0, self.width, 0);
    if (image.size.height / image.size.width > self.height / self.width) {
        self.imageView.height = floor(image.size.height / (image.size.width / self.width));
    }else {
        CGFloat height = image.size.height / image.size.width * self.width;;
        self.imageView.height = floor(height);
        self.imageView.centerY = self.height / 2;
    }
    if (self.imageView.height > self.height && self.imageView.height - self.height <= 1) {
        self.imageView.height = self.height;
    }
    self.contentSize = CGSizeMake(self.width, MAX(self.imageView.height, self.height));
    [self setContentOffset:CGPointZero];
    
    if (self.imageView.height > self.height) {
        self.alwaysBounceVertical = YES;
    } else {
        self.alwaysBounceVertical = NO;
    }

    if (self.imageView.contentMode != UIViewContentModeScaleToFill) {
        self.imageView.contentMode =  UIViewContentModeScaleToFill;
        self.imageView.clipsToBounds = NO;
    }
}

- (void)layoutSubviews {
    
    [super layoutSubviews];
    // 图片在移动的时候停止居中布局
    if (self.imageViewIsMoving == YES) return;

    CGSize boundsSize = self.bounds.size;
    CGRect frameToCenter =  self.imageView.frame;
    // Horizontally floor：如果参数是小数，则求最大的整数但不大于本身.
    if (frameToCenter.size.width < boundsSize.width) {
        frameToCenter.origin.x = floorf((boundsSize.width - frameToCenter.size.width) / 2.0);
    } else {
        frameToCenter.origin.x = 0;
    }

    // Vertically
    if (frameToCenter.size.height < boundsSize.height) {
        frameToCenter.origin.y = floorf((boundsSize.height - frameToCenter.size.height) / 2.0);
    } else {
        frameToCenter.origin.y = 0;
    }
    // Center
    if (!CGRectEqualToRect( self.imageView.frame, frameToCenter)){
        self.imageView.frame = frameToCenter;
    }
  
}
#pragma mark - 动画
- (void)addFadeAnimationWithDuration:(NSTimeInterval)duration curve:(UIViewAnimationCurve)curve ForLayer:(CALayer *)layer{
    if (duration <= 0) return;
    
    NSString *mediaFunction;
    switch (curve) {
        case UIViewAnimationCurveEaseInOut: {
            mediaFunction = kCAMediaTimingFunctionEaseInEaseOut;
        } break;
        case UIViewAnimationCurveEaseIn: {
            mediaFunction = kCAMediaTimingFunctionEaseIn;
        } break;
        case UIViewAnimationCurveEaseOut: {
            mediaFunction = kCAMediaTimingFunctionEaseOut;
        } break;
        case UIViewAnimationCurveLinear: {
            mediaFunction = kCAMediaTimingFunctionLinear;
        } break;
        default: {
            mediaFunction = kCAMediaTimingFunctionLinear;
        } break;
    }
    
    CATransition *transition = [CATransition animation];
    transition.duration = duration;
    transition.timingFunction = [CAMediaTimingFunction functionWithName:mediaFunction];
    transition.type = kCATransitionFade;
    [layer addAnimation:transition forKey:@"llb.fade"];
}

- (void)removePreviousFadeAnimationForLayer:(CALayer *)layer {
    [layer removeAnimationForKey:@"llb.fade"];
}


#pragma mark - UIScrollViewDelegate

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return self.imageView;
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView {
    if (self.model.isShowing == NO) return;
    self.model.scale = @(scrollView.zoomScale);
    [self setNeedsLayout];
    [self layoutIfNeeded];
}
- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(nullable UIView *)view atScale:(CGFloat)scale{
    if (scrollView.minimumZoomScale != scale) return;
    [self setZoomScale:self.minimumZoomScale animated:YES];
//    [self resetScrollViewStatusWithImage:self.model.currentPageImage];
    [self setNeedsLayout];
    [self layoutIfNeeded];

}


- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (self.model.isShowing == NO) return;
    self.model.contentOffset = scrollView.contentOffset;
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    if (self.imageView.height > SCREEN_HEIGHT) {
        [[LBPhotoBrowserManager defaultManager].currentCollectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:self.model.index inSection:0] atScrollPosition:UICollectionViewScrollPositionNone animated:YES];
    }
}

#pragma mark - imageView点击事件的处理方法

- (void)handlesingleTap:(CGPoint)touchPoint {
    if (_loadingView) {
        [_loadingView removeFromSuperview];
    }
    if ([[LBPhotoBrowserManager defaultManager].imageViewSuperView isKindOfClass:[UICollectionView class]]) {
        [self configCollectionViewAnimationStyle];
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:LBImageViewWillDismissNot object:nil];
    LBPhotoBrowserManager *mgr = [LBPhotoBrowserManager defaultManager];
//    UIView *currentView  = mgr.imageViews[mgr.currentPage];
    CGRect currentViewFrame =  [mgr.frames[mgr.currentPage] CGRectValue];
    self.oldFrame = [mgr.imageViewSuperView convertRect:currentViewFrame toView:[UIApplication sharedApplication].keyWindow];
    UIImageView *dismissView = self.imageView;
    self.imageViewIsMoving = YES;
    weak_self;
    [UIView animateWithDuration:0.2 animations:^{
        wself.zoomScale = scrollViewMinZoomScale;
        wself.contentOffset = CGPointZero;
        dismissView.frame = wself.oldFrame;
        dismissView.contentMode = UIViewContentModeScaleAspectFill;
        dismissView.clipsToBounds = YES;
        if (wself.model.currentPageImage.images.count > 0) {
            dismissView.image = wself.model.currentPageImage;
        }
        [LBPhotoBrowserManager defaultManager].currentCollectionView.superview.backgroundColor = [UIColor clearColor];
    }completion:^(BOOL finished) {
        [UIView animateWithDuration:0.15 delay:0 options:UIViewAnimationOptionCurveLinear animations:^{
            wself.imageView.alpha = 0;
        } completion:^(BOOL finished) {
            [dismissView removeFromSuperview];
            [wself removeFromSuperview];
            [[NSNotificationCenter defaultCenter] postNotificationName:LBImageViewDidDismissNot object:nil];
        }];
    }];
}

- (void)handleDoubleTap:(CGPoint)touchPoint {
    if (self.maximumZoomScale == self.minimumZoomScale) {
        return;
    }
    
    if (self.zoomScale != self.minimumZoomScale) {
        [self setZoomScale:self.minimumZoomScale animated:YES];
    } else {
        CGFloat newZoomScale = self.maximumZoomScale ;
        CGFloat xsize = self.bounds.size.width / newZoomScale;
        CGFloat ysize = self.bounds.size.height / newZoomScale;
        [self zoomToRect:CGRectMake(touchPoint.x - xsize/2, touchPoint.y - ysize/2, xsize, ysize) animated:YES];
    }
}

- (void)configCollectionViewAnimationStyle {
    NSDictionary *info = [LBPhotoBrowserManager defaultManager].linkageInfo;
    NSString *reuseIdentifier = info[LBLinkageInfoReuseIdentifierKey];
    if (!reuseIdentifier) {
        LBPhotoBrowserLog(@"请设置传入collectionViewCell的reuseIdentifier");
    }
    NSUInteger style = UICollectionViewScrollPositionCenteredHorizontally;
    if (info[LBLinkageInfoStyleKey]) {
        style = [info[LBLinkageInfoStyleKey] unsignedIntValue];
    }
    UICollectionView *collectionView = (UICollectionView *)[LBPhotoBrowserManager defaultManager].imageViewSuperView;
    NSIndexPath *index = [NSIndexPath indexPathForItem:[LBPhotoBrowserManager defaultManager].currentPage inSection:0];
    [collectionView scrollToItemAtIndexPath:index atScrollPosition:style animated:NO];
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:index];
    NSValue* value  = [NSValue valueWithCGRect:cell.frame];
    [[LBPhotoBrowserManager defaultManager].frames replaceObjectAtIndex:index.row withObject:value];
}
@end
