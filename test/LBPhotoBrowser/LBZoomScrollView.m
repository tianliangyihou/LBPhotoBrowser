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

LB_LastMovedOrAnimationedImageView
LB_CurrentSelectImageViewIndex

static CGFloat scrollViewMinZoomScale = 1.0;
static CGFloat scrollViewMaxZoomScale = 3.0;


@interface LBZoomScrollView ()<UIScrollViewDelegate,LBTapDetectingImageViewDelegate,UIGestureRecognizerDelegate>

@property (nonatomic , weak)LBTapDetectingImageView *imageView;
@property (nonatomic , weak)LBLoadingView *loadingView;

@property (nonatomic , assign)CGSize imageSize;
@property (nonatomic , assign)BOOL imageViewIsMoving;
@property (nonatomic , strong)NSURL *url;
@property (nonatomic , assign)CGRect oldFrame;
@property (nonatomic , assign)BOOL shouldAnimation;
@property (nonatomic , weak)id statusModel;

// 自定义的放大后 拖拽消失的方法
@property (nonatomic , assign)CGPoint startPoint;

// style1
@property (nonatomic , weak)UIImageView *appearanceImageView;
@property (nonatomic , assign)CGFloat dragBeginScrollViewContentOffsetX;
@property (nonatomic , assign)CGFloat dragBeginImageViewCenterX;

//style2
@property (nonatomic , weak)UIView *scollViewSuperView;

@end

@implementation LBZoomScrollView

- (UIImageView *)appearanceImageView {
    if (!_appearanceImageView) {
        UIImageView *imageView  = [[UIImageView alloc]initWithImage:self.imageView.image];
        imageView.frame = CGRectMake(-self.contentOffset.x + self.imageView.left,30, self.imageView.width, self.imageView.height);
        [[UIApplication sharedApplication].keyWindow addSubview:imageView];
        _appearanceImageView = imageView;
        _dragBeginScrollViewContentOffsetX = imageView.left;
        _dragBeginImageViewCenterX = imageView.centerX;

    }
    return _appearanceImageView;
}

- (LBTapDetectingImageView *)imageView {
    if (!_imageView) {
        LBTapDetectingImageView *imageView  = [[LBTapDetectingImageView alloc]init];
        imageView.tapDelegate = self;
        [self addSubview:imageView];
        _imageView = imageView;
    }
    return _imageView;
}

- (LBLoadingView *)loadingView {
    if (!_loadingView) {
        LBLoadingView *loadingView = [[LBLoadingView alloc]initWithFrame:CGRectMake(0, 0, 50, 50)];
        loadingView.center = self.center;
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
        self.showsHorizontalScrollIndicator = NO;
        self.showsVerticalScrollIndicator = NO;
        self.decelerationRate = UIScrollViewDecelerationRateFast;
        self.frame = [UIScreen mainScreen].bounds;
        self.bounces = NO;
        self.panGestureRecognizer.delegate = self;
        [self imageView];
    }
    return self;
}


- (void)showWithURL:(NSURL *)url andwithAnimation:(BOOL)animation andWithStatusModel:(id)model{

    _url = url;
    _shouldAnimation = animation;
    _statusModel = model;
    
    LBPhotoBrowserManager *mgr = [LBPhotoBrowserManager defaultManager];
    if (animation) {
        UIImageView *animationImageView = (UIImageView *)mgr.imageViews[mgr.selectedIndex];
        animationImageView.hidden = YES;
        CGRect rect = [mgr.imageViewSuperView convertRect: animationImageView.frame toView:[UIApplication sharedApplication].keyWindow];
        self.oldFrame = rect;
    }
    
    UIImage *currentImage = [self.statusModel valueForKey:@"currentPageImage"];
    if (currentImage) {
        if (_loadingView) {
            [_loadingView removeFromSuperview];
        }
    }else {
        [self loadingView];
        if (mgr.placeHoldImageCallBackBlock) {
            currentImage =  mgr.placeHoldImageCallBackBlock([NSIndexPath indexPathForItem:[mgr.urls indexOfObject:url] inSection:0]);
        }else {
            currentImage =[UIImage imageNamed:@"LBLoading.png"];
        }
    }
    [self adjustImageViewStatusWithImage:currentImage];
    
}


- (void)adjustImageViewStatusWithImage:(UIImage *)image {
    weak_self;
    self.imageSize = [self newSizeForImageViewWithImage:image];
    [self resetScrollViewStatus];
    CGRect photoImageViewFrame;
    photoImageViewFrame.origin = CGPointZero;
    photoImageViewFrame.size = self.imageSize;
    if (self.shouldAnimation) {
        self.imageViewIsMoving = YES;
        self.imageView.frame = self.oldFrame;
        
        [ UIView animateWithDuration:0.25 animations:^{
            wself.imageView.frame = photoImageViewFrame;
            wself.imageView.center = [UIApplication sharedApplication].keyWindow.center;
        }completion:^(BOOL finished) {
            wself.imageViewIsMoving = NO;
            [wself layoutSubviews];// sometime need layout
        }];
        
    }else {
        self.imageView.frame = photoImageViewFrame;
        self.imageView.center = [UIApplication sharedApplication].keyWindow.center;
    }
    // if not clear this image ,gif image may have some thing wrong
    self.imageView.image = nil;
    self.imageView.image = image;
    self.contentSize = photoImageViewFrame.size;
    [self setNeedsLayout];
}

- (void)resetScrollViewStatus {
    self.minimumZoomScale = scrollViewMinZoomScale;
    self.maximumZoomScale = scrollViewMaxZoomScale;
    self.zoomScale = scrollViewMinZoomScale;
    self.contentSize = CGSizeMake(0, 0);
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

#pragma mark - 比例尺寸处理
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


#pragma mark - UIScrollViewDelegate

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return self.imageView;
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView {
    if ([[self.statusModel valueForKeyPath:@"isDisplaying"] boolValue] == NO) return;
    [self.statusModel setValue:@(scrollView.zoomScale) forKeyPath:@"scale"];
    [self setNeedsLayout];
    [self layoutIfNeeded];
}
- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(nullable UIView *)view atScale:(CGFloat)scale{
    if (scrollView.minimumZoomScale != scale) return;
    [self setZoomScale:self.minimumZoomScale animated:YES];
    self.imageView.frame = CGRectMake(0, 0, self.imageSize.width, self.imageSize.height);
    self.frame = [UIScreen mainScreen].bounds;
    self.contentSize = self.imageView.frame.size;
    [self setNeedsLayout];
}


- (void)scrollViewDidScroll:(UIScrollView *)scrollView {

    if ([[self.statusModel valueForKeyPath:@"isDisplaying"] boolValue] == NO) return;
    [self.statusModel setValue:@(scrollView.contentOffset.x) forKeyPath:@"contentOffsetX"];
    [self.statusModel setValue:@(scrollView.contentOffset.y) forKeyPath:@"contentOffsetY"];

}

#pragma mark - imageView的代理方法
- (void)imageView:(UIImageView *)imageView doubleTapDetected:(UITouch *)touch {
    [self handleDoubleTap:[touch locationInView:imageView]];
}

- (void)imageView:(UIImageView *)imageView singleTapDetected:(UITouch *)touch {
    [self handlesingleTap:[touch locationInView:imageView]];
}

- (void)imageViewIsMovingWithImageView:(LBTapDetectingImageView *)imageView {
    self.imageViewIsMoving = YES;
}

- (void)imageViewEndMoveImageView:(LBTapDetectingImageView *)imageView {
    self.imageViewIsMoving = NO;
}

- (void)imageViewNeedRemoveFromSuperView {
    [self handlesingleTap:CGPointZero];
}

#pragma mark - imageView点击事件的处理方法

- (void)handlesingleTap:(CGPoint)touchPoint {
    if (_loadingView) {
        [_loadingView removeFromSuperview];
    }
    LBPhotoBrowserManager *mgr = [LBPhotoBrowserManager defaultManager];
    
    UIImageView *movedImageView = lastMovedOrAnimationedImageView();
    movedImageView.hidden = NO;
    
    int selectIndex = currentSelectImageViewIndex();
    UIImageView *currentMovedImageView  = mgr.imageViews[selectIndex];
    
    currentMovedImageView.hidden = YES;
    self.oldFrame = [mgr.imageViewSuperView convertRect:currentMovedImageView.frame toView:[UIApplication sharedApplication].keyWindow];
    
    UIView *dismissView = nil;
    if (touchPoint.x == -1 && touchPoint.y == -1) {
        if ([LBPhotoBrowserManager defaultManager].style == LBMaximalImageViewOnDragDismmissStyleOne) {
            dismissView = self.appearanceImageView;
        }else {
            dismissView = self.imageView;
            dismissView.frame = CGRectMake(self.left, self.top, self.width, self.height);
        }
    }else {
        dismissView = self.imageView;
    }
    
    //Views can have only one superview. If view already has a superview and that view is not the receiver, this method removes the previous superview before making the receiver its new superview.
    if (dismissView.superview != [UIApplication sharedApplication].keyWindow) {
        [[UIApplication sharedApplication].keyWindow addSubview:dismissView];
    }
    
    self.imageViewIsMoving = YES;
    [[NSNotificationCenter defaultCenter] postNotificationName:LBImageViewWillDismissNot object:nil];
    weak_self;
    [UIView animateWithDuration:0.25 animations:^{
        dismissView.frame = wself.oldFrame;
        
    }completion:^(BOOL finished) {
        [dismissView removeFromSuperview];
        [wself removeFromSuperview];
        currentMovedImageView.hidden = NO;
        [[NSNotificationCenter defaultCenter] postNotificationName:LBImageViewDidDismissNot object:nil];
    }];
}

- (void)handleDoubleTap:(CGPoint)touchPoint {
    
    if (self.zoomScale != self.minimumZoomScale) {
        [self setZoomScale:self.minimumZoomScale animated:YES];
    } else {
        CGFloat newZoomScale =self.maximumZoomScale ;
        CGFloat xsize = self.bounds.size.width / newZoomScale;
        CGFloat ysize = self.bounds.size.height / newZoomScale;
        [self zoomToRect:CGRectMake(touchPoint.x - xsize/2, touchPoint.y - ysize/2, xsize, ysize) animated:YES];
    }
}

#pragma mark - 手势的代理  为放大高度超过屏幕的ImageView添加拖拽消失手势-

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    if (self.contentOffset.y == 0 && self.imageView.height > SCREEN_HEIGHT && gestureRecognizer.numberOfTouches == 1) {
        if ([LBPhotoBrowserManager defaultManager].style == LBMaximalImageViewOnDragDismmissStyleOne) {
            [gestureRecognizer addTarget:self action:@selector(lb_touchMoveStyleOne:)];
        }else {
            [gestureRecognizer addTarget:self action:@selector(lb_touchMoveStyleTwo:)];
        }
    }
    return YES;
}

- (void)lb_touchMoveStyleOne:(UIPanGestureRecognizer *)pan  {
    CGPoint point = [pan locationInView:[UIApplication sharedApplication].keyWindow];
    if (pan.state == UIGestureRecognizerStateBegan) {
        _startPoint = point;
    }else if (pan.state == UIGestureRecognizerStateChanged) {
        
        CGFloat deviationY = point.y - _startPoint.y;
        CGFloat deviationX = point.x - _startPoint.x;
        // 只要deviationY 大于 30 父View = [UIApplication sharedApplication].keyWindow
        if (deviationY > 30) {
            if (!_appearanceImageView || _appearanceImageView.superview != [UIApplication sharedApplication].keyWindow) {
                [[UIApplication sharedApplication].keyWindow addSubview:self.appearanceImageView];
                [[NSNotificationCenter defaultCenter] postNotificationName:LBAddCoverImageViewNot object:nil];
            }
        }
        // 只要deviationY 小于或者等于30 父View = [UIApplication sharedApplication].keyWindow
        if (deviationY <=30 && _appearanceImageView) {
            [_appearanceImageView removeFromSuperview];
            [[NSNotificationCenter defaultCenter] postNotificationName:LBRemoveCoverImageViewNot object:nil];
        }
        // 保证背景View的颜色变化 --> 150
        CGFloat ratio = (LB_DISMISS_DISTENCE-deviationY)/LB_DISMISS_DISTENCE;
        [LBPhotoBrowserManager defaultManager].currentCollectionView.superview.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:ratio];
        
        if (deviationY <= 30) {
            _startPoint = CGPointMake(point.x,_startPoint.y);
        }
        
        if (deviationY > 30) {
            self.imageView.hidden = YES;
            self.appearanceImageView.top = deviationY;
            self.appearanceImageView.width = self.imageView.width * ratio;
            self.appearanceImageView.height = self.imageView.height * ratio;
            self.appearanceImageView.centerX = self.dragBeginImageViewCenterX + deviationX;
            
        }else {
            self.imageView.hidden = NO;
        }
        
    }else if (pan.state == UIGestureRecognizerStateEnded) {
        [self.panGestureRecognizer removeTarget:self action:@selector(lb_touchMoveStyleOne:)];
        if (self.appearanceImageView.top > 200) {
            [self handlesingleTap:CGPointMake(-1, -1)];
            return;
        }
        CGFloat deviationY = point.y - _startPoint.y;
        if (deviationY <= 30) {
            [self.appearanceImageView removeFromSuperview];
            [[NSNotificationCenter defaultCenter] postNotificationName:LBRemoveCoverImageViewNot object:nil];
            self.imageView.hidden = NO;
            return;
        }
        weak_self;
        self.dragBeginScrollViewContentOffsetX = self.contentOffset.x;
        [UIView animateWithDuration:0.35 animations:^{
            [LBPhotoBrowserManager defaultManager].currentCollectionView.superview.backgroundColor = [UIColor blackColor];
            wself.appearanceImageView.frame = CGRectMake(- wself.contentOffset.x + wself.imageView.left, 0, wself.imageView.width, wself.imageView.height);
        }completion:^(BOOL finished) {
            wself.contentOffset = CGPointMake(wself.dragBeginScrollViewContentOffsetX, 0);
            wself.imageView.hidden = NO;
            [wself.appearanceImageView removeFromSuperview];
            [[NSNotificationCenter defaultCenter] postNotificationName:LBRemoveCoverImageViewNot object:nil];
        }];
        
    }else if (pan.state == UIGestureRecognizerStateCancelled) {
        self.imageView.hidden = NO;
        [self.appearanceImageView removeFromSuperview];
        [[NSNotificationCenter defaultCenter] postNotificationName:LBRemoveCoverImageViewNot object:nil];
        [self.panGestureRecognizer removeTarget:self action:@selector(lb_touchMoveStyleOne:)];
    }else if (pan.state == UIGestureRecognizerStateFailed) {
        self.imageView.hidden = NO;
        [self.appearanceImageView removeFromSuperview];
        [[NSNotificationCenter defaultCenter] postNotificationName:LBRemoveCoverImageViewNot object:nil];
        [self.panGestureRecognizer removeTarget:self action:@selector(lb_touchMoveStyleOne:)];
    }
}

- (void)lb_touchMoveStyleTwo:(UIPanGestureRecognizer *)pan  {
    CGPoint point = [pan locationInView:[UIApplication sharedApplication].keyWindow];
    if (pan.state == UIGestureRecognizerStateBegan) {
        _startPoint = point;
        self.scollViewSuperView = self.superview;
    }else if (pan.state == UIGestureRecognizerStateChanged) {
        CGFloat deviationY = point.y - _startPoint.y;
        CGFloat deviationX = point.x - _startPoint.x;
        self.top = deviationY;
        // 只要deviationY 大于 30 父View = [UIApplication sharedApplication].keyWindow
        if (deviationY > 30 && self.superview != [UIApplication sharedApplication].keyWindow) {
            [[UIApplication sharedApplication].keyWindow addSubview:self];
        }
        // 只要deviationY 小于或者等于 30 父View = [UIApplication sharedApplication].keyWindow
        if (deviationY <=30 && self.superview!= self.scollViewSuperView) {
            [self.scollViewSuperView addSubview:self];
        }
        // 保证背景View的颜色变化 --> 150
        if (deviationY > 150) {
            [LBPhotoBrowserManager defaultManager].currentCollectionView.superview.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:(LB_DISMISS_DISTENCE-deviationY)/(LB_DISMISS_DISTENCE - 30)];
        }else {
            [LBPhotoBrowserManager defaultManager].currentCollectionView.superview.backgroundColor = [UIColor blackColor];
        }
        
        if (deviationY <= 30) {
            _startPoint = CGPointMake(point.x,_startPoint.y);
        }
        // 调整ScrollView的frame
        if (deviationY > 30) {
            self.left = deviationX;
        }else {
            self.left = 0;
        }
        
    }else if (pan.state == UIGestureRecognizerStateEnded) {
        
        if (self.top > 200) {
            [self handlesingleTap:CGPointMake(-1, -1)];
        }
        [self.scollViewSuperView addSubview:self];
        [UIView animateWithDuration:0.25 animations:^{
            self.top = 0;
            self.left = 0;
            [LBPhotoBrowserManager defaultManager].currentCollectionView.superview.backgroundColor = [UIColor blackColor];
        }];
        [self.panGestureRecognizer removeTarget:self action:@selector(lb_touchMoveStyleTwo:)];
    }else if (pan.state == UIGestureRecognizerStateCancelled) {
        [self.scollViewSuperView addSubview:self];
        [self.panGestureRecognizer removeTarget:self action:@selector(lb_touchMoveStyleTwo:)];
    }else if (pan.state == UIGestureRecognizerStateFailed) {
        [self.scollViewSuperView addSubview:self];
        [self.panGestureRecognizer removeTarget:self action:@selector(lb_touchMoveStyleTwo:)];
    }
}

@end
