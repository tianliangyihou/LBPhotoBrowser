//
//  LBPhotoBrowseManager.m
//  test
//
//  Created by dengweihao on 2017/8/1.
//  Copyright © 2017年 dengweihao. All rights reserved.
//

#import "LBPhotoBrowserManager.h"
#import "UIImage+LBDecoder.h"
#import "LBZoomScrollView.h"
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

static inline void resetManagerData(LBPhotoBrowserView *photoBrowseView, LBUrlsMutableArray *urls ,LBFramesMutableArray *frames, LBImagesMutableArray *images) {
    [urls removeAllObjects];
    [frames removeAllObjects];
    [images removeAllObjects];
    if (photoBrowseView) {
        [photoBrowseView removeFromSuperview];
    }
}

@implementation LBPhotoWebItem
- (instancetype)init
{
    self = [super init];
    if (self) {
        _frame = CGRectZero;
        _placeholdSize = CGSizeZero;
        _urlString = @"";
    }
    return self;
}
- (instancetype)initWithURLString:(NSString *)url frame:(CGRect)frame {
    LBPhotoWebItem *item  = [self init];
    item.urlString = url;
    item.frame = frame;
    return item;
}

- (instancetype)initWithURLString:(NSString *)url frame:(CGRect)frame placeholdSize:(CGSize)size {
    LBPhotoWebItem *item = [self initWithURLString:url frame:frame];
    item.placeholdSize = size;
    return item;
}

- (instancetype)initWithURLString:(NSString *)url frame:(CGRect)frame placeholdImage:(UIImage *)image {
    LBPhotoWebItem *item = [self initWithURLString:url frame:frame];
    item.placeholdImage = image;
    return item;
}

- (instancetype)initWithURLString:(NSString *)url frame:(CGRect)frame placeholdImage:(UIImage *)image placeholdSize:(CGSize)size  {
    LBPhotoWebItem *item = [self initWithURLString:url frame:frame placeholdImage:image];
    item.placeholdSize = size;
    return item;
}

@end

@implementation LBPhotoLocalItem

- (instancetype)initWithImage:(UIImage *)image frame:(CGRect)frame {
    LBPhotoLocalItem *item = [[LBPhotoLocalItem alloc]init];
    item.localImage = image;
    item.frame = frame;
    return item;
}

@end

@interface LBPhotoBrowserManager () {
    NSOperationQueue *_requestQueue;
    dispatch_semaphore_t _lock;
}
@property (nonatomic , copy)void (^titleClickBlock)(UIImage *, NSIndexPath *, NSString *);

@property (nonatomic , copy)UIView *(^longPressCustomViewBlock)(UIImage *, NSIndexPath *);

@property (nonatomic , copy)void(^willDismissBlock)(void);

@property (nonatomic , copy)void(^didDismissBlock)(void);



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

@synthesize frames = _frames;

@synthesize images = _images;

@synthesize linkageInfo = _linkageInfo;

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (LBUrlsMutableArray *)urls {
    if (!_urls) {
        _urls = [[LBUrlsMutableArray alloc]init];
    }
    return _urls;
}

- (LBFramesMutableArray *)frames {
    if (!_frames) {
        _frames = [[LBFramesMutableArray alloc]init];
    }
    return _frames;
}

- (LBImagesMutableArray *)images {
    if (!_images) {
        _images = [[NSMutableArray alloc]init];
    }
    return _images;
}

- (NSMutableDictionary *)linkageInfo {
    if (!_linkageInfo) {
        _linkageInfo = [[NSMutableDictionary alloc]init];
    }
    return _linkageInfo;
}

+ (instancetype)defaultManager {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        mgr = [[self alloc]init];
    });
    return mgr;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.errorImage = [UIImage imageNamed:@"LBLoadError.jpg"];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(photoBrowserWillDismiss) name:LBImageViewWillDismissNot object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(photoBrowserDidDismiss) name:LBImageViewDidDismissNot object:nil];
        _requestQueue = [[NSOperationQueue alloc] init];
        _requestQueue.maxConcurrentOperationCount = 1;
        _lock = dispatch_semaphore_create(1);
        _needPreloading = YES;
    }
    return self;
}


- (instancetype)showImageWithLocalItems:(NSArray<LBPhotoLocalItem *> *)items selectedIndex:(NSInteger)index fromImageViewSuperView:(UIView *)superView {
    if (items.count == 0 || !items) {
        return nil;
    }
    resetManagerData(_photoBrowserView, self.urls, self.frames, self.images);
    for (int i = 0; i < items.count; i++) {
        LBPhotoLocalItem *item = items[i];
        if (item.localImage) {
            [self.images addObject:item.localImage];
        }
        if (!CGRectEqualToRect(item.frame, CGRectZero)) {
            [self.frames addObject:[NSValue valueWithCGRect:item.frame]];
        }
    }
    NSAssert(self.images.count == self.frames.count, @"请检查传入item的localImage 和 frame");
    
    _currentPage = index;
    _imageViewSuperView = superView;
    LBPhotoBrowserView *photoBrowserView = [[LBPhotoBrowserView alloc]initWithFrame:[UIScreen mainScreen].bounds];
    [photoBrowserView showImageViewsWithImages:self.images andSeletedIndex:(int)index];
    [photoBrowserView makeKeyAndVisible];
    _photoBrowserView = photoBrowserView;
    return self;
}

- (instancetype)showImageWithWebItems:(NSArray<LBPhotoWebItem *> *)items selectedIndex:(NSInteger)index fromImageViewSuperView:(UIView *)superView {
    NSMutableDictionary *placeHoldImageDic = [[NSMutableDictionary alloc]initWithCapacity:items.count];
    NSMutableDictionary *placeholdSizeDic = [[NSMutableDictionary alloc]initWithCapacity:items.count];
    NSMutableArray *frames = [[NSMutableArray alloc]initWithCapacity:items.count];
    NSMutableArray *urls = [[NSMutableArray alloc]initWithCapacity:items.count];
    for (int i = 0; i < items.count; i++) {
        LBPhotoWebItem *item = items[i];
        if (!item.urlString || CGRectEqualToRect(item.frame, CGRectZero)) {
            return nil;
        }
        [urls addObject:item.urlString];
        [frames addObject:[NSValue valueWithCGRect:item.frame]];
        NSString *index = [NSString stringWithFormat:@"%d",i];
        placeHoldImageDic[index] = item.placeholdImage;
        placeholdSizeDic[index] = CGSizeEqualToSize(item.placeholdSize, CGSizeZero)? nil:[NSValue valueWithCGSize:item.placeholdSize];
    }
    return  [[[self showImageWithURLArray:urls fromImageViewFrames:frames selectedIndex:index imageViewSuperView:superView] addPlaceholdImageSizeBlock:^CGSize(UIImage *Image, NSIndexPath *indexpath) {
        NSString *index = [NSString stringWithFormat:@"%ld",(long)indexpath.row];
        CGSize size = [placeholdSizeDic[index] CGSizeValue];
        return size;
    }] addPlaceholdImageCallBackBlock:^UIImage *(NSIndexPath *indexPath) {
        NSString *index = [NSString stringWithFormat:@"%ld",(long)indexPath.row];
        return placeHoldImageDic[index];
    }] ;
}

- (instancetype)showImageWithURLArray:(NSArray *)urls fromImageViewFrames:(NSArray *)frames selectedIndex:(NSInteger)index imageViewSuperView:(UIView *)superView {
    
    if (urls.count == 0 || !urls) return nil;
    if (frames.count == 0 || !frames) return nil;
    
    resetManagerData(_photoBrowserView, self.urls, self.frames, self.images);
    for (id obj in urls) {
        NSURL *url = nil;
        if ([obj isKindOfClass:[NSURL class]]) {
            url = obj;
        }
        if ([obj isKindOfClass:[NSString class]]) {
            url = [NSURL URLWithString:obj];
        }
        if (!url) {
            url = [NSURL URLWithString:@"https://LBPhotoBrowser.error"];
            LBPhotoBrowserLog(@"传入的链接%@有误",obj);
        }
        [self.urls addObject:url];
    }
    
    for (id obj in frames) {
        NSValue *value = nil;
        if ([obj isKindOfClass:[NSValue class]]) {
            value = obj;
        }
        if (!value) {
            value = [NSValue valueWithCGRect:CGRectZero];
            LBPhotoBrowserLog(@"传入的frame %@有误",obj);
        }
        [self.frames addObject:value];
    }
    NSAssert(self.urls.count == self.frames.count, @"请检查传入item的url 和 frame");
    
    _currentPage = index;
    _imageViewSuperView = superView;
    LBPhotoBrowserView *photoBrowserView = [[LBPhotoBrowserView alloc]initWithFrame:[UIScreen mainScreen].bounds];
    [photoBrowserView showImageViewsWithURLs:self.urls andSelectedIndex:(int)index];
    [photoBrowserView makeKeyAndVisible];
    _photoBrowserView = photoBrowserView;
    return self;
    
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

- (instancetype)addPlaceholdImageCallBackBlock:(UIImage *(^)(NSIndexPath *))placeholdImageCallBackBlock {
    _placeholdImageCallBackBlock = placeholdImageCallBackBlock;
    return self;
}

- (instancetype)addPhotoBrowserWillDismissBlock:(void (^)(void))dismissBlock {
    _willDismissBlock = dismissBlock;
    return self;
}

- (instancetype)addPhotoBrowserDidDismissBlock:(void (^)(void))dismissBlock {
    _didDismissBlock = dismissBlock;
    return self;
}

- (instancetype)addPlaceholdImageSizeBlock:(CGSize (^)(UIImage *, NSIndexPath *))placeholdImageSizeBlock {
    _placeholdImageSizeBlock = placeholdImageSizeBlock;
    return self;
}

- (instancetype)addCollectionViewLinkageStyle:(UICollectionViewScrollPosition)style cellReuseIdentifier:(NSString *)reuseIdentifier {
    self.linkageInfo[LBLinkageInfoStyleKey] = @(style);
    self.linkageInfo[LBLinkageInfoReuseIdentifierKey] = reuseIdentifier;
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

- (void)photoBrowserWillDismiss {
    [self displayLinkInvalidate];
    if(self.willDismissBlock) {
        self.willDismissBlock();
    }
    self.willDismissBlock = nil;
}

- (void)photoBrowserDidDismiss {
    if (self.didDismissBlock) {
        self.didDismissBlock();
    }
    self.didDismissBlock = nil;
    self.needPreloading = YES;
    self.lowGifMemory = NO;
    _photoBrowserView.hidden = YES;
    _photoBrowserView = nil;
    [self.linkageInfo removeAllObjects];
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
    
    _longPressCustomViewBlock = nil;
    _titleClickBlock = nil;
    _placeholdImageCallBackBlock = nil;
    _placeholdImageSizeBlock = nil;
    _titles = @[];
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
    LBZoomScrollView * zoomScrollView = (LBZoomScrollView *)superView;
    NSURL *currentUrl = zoomScrollView.model.url;
    // 异步查询图片
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
