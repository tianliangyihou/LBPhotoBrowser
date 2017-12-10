//
//  LBPhotoBrowseManager.m
//  test
//
//  Created by dengweihao on 2017/8/1.
//  Copyright © 2017年 dengweihao. All rights reserved.
//

#import "LBPhotoBrowserManager.h"
#import "UIImage+LBDecoder.h"
#import <ImageIO/ImageIO.h>

#if __has_include(<SDWebImage/SDWebImageManager.h>)

#import <SDWebImage/SDWebImageManager.h>
#import <SDWebImage/UIImageView+WebCache.h>
#import <SDWebImage/UIImage+MultiFormat.h>

#else

#import "SDWebImageManager.h"
#import "UIImageView+WebCache.h"
#import "UIImage+MultiFormat.h"

#endif

#define LOCK(...) dispatch_semaphore_wait(_lock, DISPATCH_TIME_FOREVER); \
__VA_ARGS__; \
dispatch_semaphore_signal(_lock);

static LBPhotoBrowserManager *mgr = nil;

static inline void resetManagerData(LBPhotoBrowserView *photoBrowseView, LBUrlsMutableArray *urls ,LBImageViewsArray *imageViews) {
    [urls removeAllObjects];
    [imageViews removeAllObjects];
    if (photoBrowseView) {
        [photoBrowseView removeFromSuperview];
    }
}

@interface LBPhotoBrowserManager () {
    NSOperationQueue *_requestQueue;
    dispatch_semaphore_t _lock;
}
@property (nonatomic , copy)void (^titleClickBlock)(UIImage *, NSIndexPath *, NSString *);

@property (nonatomic , copy)UIView *(^longPressCustomViewBlock)(UIImage *, NSIndexPath *);

@property (nonatomic , copy)void(^dismissBlock)(void);


@property (nonatomic , strong)NSArray *titles;

@property (nonatomic , strong)NSData *spareData;

// timer
// in ios 9 this property can be weak Replace strong
@property (nonatomic , strong)CADisplayLink *displayLink;
@property (nonatomic , assign) NSTimeInterval accumulator;
@property (nonatomic , strong)UIImage *currentGifImage;
@end

@interface LBDecoderOperation : NSOperation
@property (nonatomic, assign) NSUInteger nextIndex;
@property (nonatomic, strong) UIImage *curImage;
@property (nonatomic , weak)dispatch_semaphore_t lock;

@end

@implementation LBPhotoBrowserManager

@synthesize urls = _urls;

@synthesize imageViews = _imageViews;

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (LBUrlsMutableArray *)urls {
    if (!_urls) {
        _urls = [[LBUrlsMutableArray alloc]init];
    }
    return _urls;
}


- (LBImageViewsArray *)imageViews {
    if (!_imageViews) {
        _imageViews = [[LBImageViewsArray alloc]init];
    }
    return _imageViews;
}

- (LBPhotoBrowserShowHelper *)helper {
    if (!_helper) {
        _helper = [[LBPhotoBrowserShowHelper alloc]init];
    }
    return _helper;
}

+ (instancetype)defaultManager {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        mgr = [[self alloc]init];
        mgr.style = LBMaximalImageViewOnDragDismmissStyleOne;
    });
    return mgr;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.isNeedBounces = YES;
        self.showBrowserWithAnimation = YES;
        self.errorImage = [UIImage imageNamed:@"LBLoadError.jpg"];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(displayLinkInvalidate) name:LBImageViewWillDismissNot object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(stopDisplayLink) name:LBAddCoverImageViewNot object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(resumeDipaplayLink) name:LBRemoveCoverImageViewNot object:nil];
        _requestQueue = [[NSOperationQueue alloc] init];
        _requestQueue.maxConcurrentOperationCount = 1;
        _lock = dispatch_semaphore_create(1);
    }
    return self;
}

- (instancetype)showImageWithURLArray:(NSArray *)urls fromImageViews:(NSArray *)imageViews selectedIndex:(int)index imageViewSuperView:(UIView *)superView {
    
    if (urls.count == 0 || !urls) return nil;
    if (imageViews.count == 0 || !imageViews) return nil;
    
    resetManagerData(_photoBrowserView, self.urls, self.imageViews);
    for (id obj in urls) {
        NSURL *url = nil;
        if ([obj isKindOfClass:[NSURL class]]) {
            url = obj;
        }
        if ([obj isKindOfClass:[NSString class]]) {
            if (isRemoteAddress((NSString *)obj)){
                url = [NSURL URLWithString:obj];
            }else {
                url = [NSURL fileURLWithPath:obj];
            }
        }
        if (!url) {
            url = [NSURL URLWithString:@"https://LBPhotoBrowser.error"];
            LBPhotoBrowserLog(@"传的链接%@有误",obj);
        }
        [self.urls addObject:url];
    }
    
    for (id obj in imageViews) {
        UIImageView *imageView = nil;
        if ([obj isKindOfClass:[UIImageView class]]) {
            imageView = obj;
        }
        NSAssert(imageView, @"imageView数组里面的数据有问题!");
        if (imageView) {
            [self.imageViews addObject:imageView];
        }
    }
    NSAssert(self.urls.count == self.imageViews.count, @"请检查传入的urls 和 imageViews数组");
    
    _selectedIndex = index;
    _imageViewSuperView = superView;
    
    LBPhotoBrowserView *photoBrowserView = [[LBPhotoBrowserView alloc]initWithFrame:[UIScreen mainScreen].bounds];
    [photoBrowserView showImageViewsWithURLs:self.urls andSelectedIndex:index];
    [[UIApplication sharedApplication].keyWindow addSubview:photoBrowserView];
    _photoBrowserView = photoBrowserView;
    self.helper.showType = LBShowTypeViews;
    self.helper.imageViews = imageViews;
    self.helper.lastShowIndex = self.helper.currentShowIndex = index;
    return self;
    
}

- (instancetype)showImageWithURLArray:(NSArray *)urls fromCollectionView:(UICollectionView *)collectionView selectedIndex:(int)index {
    if (urls.count == 0 || !urls) return nil;
    if (!collectionView) return nil;
    
    resetManagerData(_photoBrowserView, self.urls, self.imageViews);
    for (id obj in urls) {
        NSURL *url = nil;
        if ([obj isKindOfClass:[NSURL class]]) {
            url = obj;
        }
        if ([obj isKindOfClass:[NSString class]]) {
            if (isRemoteAddress((NSString *)obj)){
                url = [NSURL URLWithString:obj];
            }else {
                url = [NSURL fileURLWithPath:obj];
            }
        }
        if (!url) {
            url = [NSURL URLWithString:@"https://LBPhotoBrowser.error"];
            LBPhotoBrowserLog(@"传的链接%@有误",obj);
        }
        [self.urls addObject:url];
    }
    _selectedIndex = index;
    _imageViewSuperView = collectionView;
    
    LBPhotoBrowserView *photoBrowserView = [[LBPhotoBrowserView alloc]initWithFrame:[UIScreen mainScreen].bounds];
    [photoBrowserView showImageWithURLArray:self.urls fromCollectionView:collectionView selectedIndex:index];
    [[UIApplication sharedApplication].keyWindow addSubview:photoBrowserView];
    _photoBrowserView = photoBrowserView;
    self.helper.showType = LBShowTypeCollectionView;
    self.helper.collectioView = collectionView;
    self.helper.lastShowIndex = self.helper.currentShowIndex = index;
    return self;
}

- (instancetype)showImageWithURLArray:(NSArray *)urls fromCollectionView:(UICollectionView *)collectionView selectedIndex:(int)index unwantedUrls:(NSArray *)unwantedUrls {
    if (urls.count == unwantedUrls.count || urls.count < unwantedUrls.count) {
        return nil;
    }
    NSMutableArray *originalStrings = [NSMutableArray arrayWithCapacity:urls.count];
    NSMutableArray *unwantedStrings = [NSMutableArray arrayWithCapacity:unwantedUrls.count];
    NSMutableArray *wantedStrings = [NSMutableArray array];
    for (int i = 0; i < urls.count; i++) {
        id obj = urls[i];
        if ([obj isKindOfClass:[NSURL class]]) {
            obj = [(NSURL *)obj absoluteString];
        }
        if (![obj isKindOfClass:[NSString class]]) {
            LBPhotoBrowserLog(@"urls传入的URL 类型必须为NSURL or NSString");
            return nil;
        }
        [originalStrings addObject:obj];
    }
    for (int i = 0; i < unwantedUrls.count; i++) {
        id obj = unwantedUrls[i];
        if ([obj isKindOfClass:[NSURL class]]) {
            obj = [(NSURL *)obj absoluteString];
        }
        if (![obj isKindOfClass:[NSString class]]) {
            LBPhotoBrowserLog(@"unwantedUrls传入的URL 类型必须为NSURL or NSString");
            return nil;
        }
        [unwantedStrings addObject:obj];
    }
    for (int i = 0; i < originalStrings.count; i++) {
        NSString *urlString = urls[i];
        if (![unwantedStrings containsObject:urlString]) {
            NSURL *url = isRemoteAddress(urlString) ?[NSURL URLWithString:urlString] : [NSURL fileURLWithPath:urlString];
            [self.helper.showIndexPathDic setObject:[NSIndexPath indexPathForRow:i inSection:0] forKey:url.absoluteString];
            [wantedStrings addObject:urlString];
        }
    }
    NSString *selectedString = originalStrings[index];
    index = (int)[wantedStrings indexOfObject:selectedString];
    return [self showImageWithURLArray:wantedStrings fromCollectionView:collectionView selectedIndex:index];
}

#pragma mark - longPressAction

- (instancetype)addLongPressShowTitles:(NSArray <NSString *> *)titles {
    _titles = titles;
    return self;
}

- (instancetype)addTitleClickCallbackBlock:(void (^)(UIImage *, NSIndexPath *, NSString *))titleClickCallBackBlock {
    _titleClickBlock = titleClickCallBackBlock;
    return self;
}
- (instancetype)addLongPressCustomViewBlock:(UIView *(^)(UIImage *, NSIndexPath *))longPressBlock {
    _longPressCustomViewBlock = longPressBlock;
    return self;
}

- (instancetype)addPlaceHoldImageCallBackBlock:(UIImage *(^)(NSIndexPath * indexPath))placeHoldImageCallBackBlock {
    _placeHoldImageCallBackBlock = placeHoldImageCallBackBlock;
    return self;
}

- (instancetype)addPhotoBrowserWillDismissBlock:(void (^)(void))dismissBlock {
    _dismissBlock = dismissBlock;
    return self;
}

- (NSArray<NSString *> *)currentTitles {
    return _titles;
}

- (void (^)(UIImage *, NSIndexPath *, NSString *))titleClickBlock {
    return _titleClickBlock;
}

- (UIView *(^)(UIImage *, NSIndexPath *))longPressCustomViewBlock {
    return _longPressCustomViewBlock;
}


#pragma mark - gif&定时器

- (CADisplayLink *)displayLink {
    if (!_displayLink) {
        _displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(changeKeyframe:)];
        [_displayLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
    }
    return _displayLink;
}

- (void)displayLinkInvalidate {
    
    if (_displayLink) {
        [_displayLink invalidate];
        _displayLink = nil;
    }
    self.currentShowImageView = nil;
    self.currentGifImage = nil;
    if (_requestQueue) {
        [_requestQueue cancelAllOperations];
    }
    if(_dismissBlock) {
        _dismissBlock();
    }
    _dismissBlock = nil;
    _longPressCustomViewBlock = nil;
    _titleClickBlock = nil;
    _placeHoldImageCallBackBlock = nil;
    _helper = nil;
}
- (void)changeKeyframe:(CADisplayLink *)displayLink
{
    if (!self.currentGifImage.images) return;
    NSMutableDictionary *buffer = self.currentGifImage.lb_imageBuffer;
    NSUInteger nextIndex = (self.currentGifImage.lb_handleIndex.intValue + 1)% self.currentGifImage.lb_totalFrameCount.intValue;
    BOOL bufferIsFull = NO;
    NSTimeInterval delay = 0;
    if (self.currentGifImage.bufferMiss.boolValue == NO) {
        self.accumulator += displayLink.duration;
        delay = [self.currentGifImage animatedImageDurationAtIndex:self.currentGifImage.lb_handleIndex.intValue];
        if (self.accumulator < delay) return;
        self.accumulator -= delay;
        delay = [self.currentGifImage animatedImageDurationAtIndex:(int)nextIndex];
        if (self.accumulator > delay) self.accumulator = delay;
    }
    UIImage *bufferedImage = buffer[@(nextIndex)];
    if (bufferedImage) {
        if (self.currentGifImage.needUpdateBuffer.boolValue) {
            [buffer removeObjectForKey:@(nextIndex)];
        }
        [self.currentGifImage lb_setHandleIndex:@(nextIndex)];
        self.currentShowImageView.image = bufferedImage;
        [self.currentGifImage lb_setBufferMiss:@(NO)];
        nextIndex = (self.currentGifImage.lb_handleIndex.intValue + 1)% self.currentGifImage.lb_totalFrameCount.intValue;
        if (buffer.count == self.currentGifImage.totalFrameCount.unsignedIntValue) {
            bufferIsFull = YES;
        }
    }else {
        [self.currentGifImage lb_setBufferMiss:@(YES)];
    }
    if (bufferIsFull == NO && _requestQueue.operationCount == 0) {
        LBDecoderOperation *operation = [LBDecoderOperation new];
        operation.nextIndex = nextIndex;
        operation.curImage = self.currentGifImage;
        operation.lock = _lock;
        [_requestQueue addOperation:operation];
    }
}

- (void)setCurrentShowImageView:(UIImageView *)currentShowImageView {
    if (_currentShowImageView && _currentShowImageView == currentShowImageView) {
        return;
    }
    _currentShowImageView = currentShowImageView;
    if (self.lowGifMemory == NO) return;
    if (!_currentShowImageView) return;
    [self startAnimation];
}

- (void)startAnimation {
    self.displayLink.paused = YES;
    weak_self;
    UIView *superView = wself.currentShowImageView.superview;
    if (![superView isKindOfClass:[UIScrollView class]]) return;
    NSURL *currentUrl = [superView valueForKeyPath:@"url"];
    if (!isRemoteAddress(currentUrl.absoluteString)) {
        NSData *imageData = [NSData dataWithContentsOfURL:currentUrl];
        UIImage *image = [UIImage sd_imageWithData:imageData];
        self.currentGifImage = image;
        [image lb_animatedGIFData:imageData];
        self.displayLink.paused = NO;
        return;
    }
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [[SDImageCache sharedImageCache] queryCacheOperationForKey:currentUrl.absoluteString done:^(UIImage * _Nullable image, NSData * _Nullable data, SDImageCacheType cacheType) {
            __block NSData *data_block = data;
            dispatch_async(dispatch_get_main_queue(), ^{
                wself.currentGifImage = image;
                if (image.images.count == 0) {
                    return ;
                }
                if (!data_block) {
                    data_block = wself.spareData;
                }
                if (!data_block) {
                    return;
                }
                wself.currentShowImageView.image = image.images.firstObject;
                [image lb_animatedGIFData:data_block];
                wself.accumulator = 0;
                wself.displayLink.paused = NO;
                wself.spareData = nil;
            });
        }];
    });
    
}
- (void)setCurrentGifImage:(UIImage *)currentGifImage {
    if (_currentGifImage == currentGifImage) {
        return;
    }
    LOCK([_currentGifImage imageViewShowFinsished]);
    _currentGifImage  = currentGifImage;
}

#pragma mark - 监听通知

- (void)stopDisplayLink {
    if (self.lowGifMemory && self.style == LBMaximalImageViewOnDragDismmissStyleOne) {
        if (_displayLink && _displayLink.paused == NO) {
            _displayLink.paused = YES;
        }
    }
}
- (void)resumeDipaplayLink {
    if (self.lowGifMemory && self.style == LBMaximalImageViewOnDragDismmissStyleOne) {
        if (_displayLink && _displayLink.paused == YES) {
            _displayLink.paused = NO;
        }
    }
}

@end

@implementation LBDecoderOperation

- (void)main {
    
    if ([self isCancelled]) return;
    int incrBufferCount = _curImage.lb_incrBufferCount.intValue;
    [_curImage lb_setIncrBufferCount:@(incrBufferCount + 1)];
    if (_curImage.lb_incrBufferCount.intValue > _curImage.lb_maxBufferCount.intValue) {
        [_curImage lb_setIncrBufferCount: _curImage.lb_maxBufferCount];
    }
    NSUInteger index = _nextIndex;
    NSUInteger max = _curImage.lb_incrBufferCount.intValue;
    NSUInteger total = _curImage.lb_totalFrameCount.intValue;
    for (int i = 0; i < max; i++, index++) {
        @autoreleasepool {
            if (index >= total) index = 0;
            if ([self isCancelled]) break;
            LOCK(BOOL miss = (_curImage.lb_imageBuffer[@(index)] == nil));
            if (miss) {
                if ([self isCancelled]) break;
                LOCK(UIImage *img = [_curImage animatedImageFrameAtIndex:(int)index]);
                if (img) {
                    LOCK([_curImage.lb_imageBuffer setObject:img forKey:@(index)]);
                }
            }
        }
    }
}
@end
