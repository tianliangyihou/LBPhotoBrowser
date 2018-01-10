//
//  LBPhotoBrowserView.m
//  test
//
//  Created by dengweihao on 2017/8/2.
//  Copyright © 2017年 dengweihao. All rights reserved.
//

#import "LBPhotoBrowserConst.h"
#import "LBPhotoBrowserManager.h"
#import "LBPhotoBrowserView.h"
#import "LBZoomScrollView.h"
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

static CGFloat const itemSpace = 20.0;

@interface LBPhotoCollectionViewCell : UICollectionViewCell

@property (nonatomic , weak)LBZoomScrollView *zoomScrollView;

@property (nonatomic , strong)LBScrollViewStatusModel *model;

- (void)startPopAnimationWithModel:(LBScrollViewStatusModel *)model completionBlock:(void(^)(void))completion;
@end

@interface LBPhotoBrowserView ()<UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout>

@property (nonatomic , weak)UICollectionView *collectionView;

@property (nonatomic , strong)NSMutableArray *dataArr;

@property (nonatomic , strong)NSMutableArray *models;

@property (nonatomic , assign)BOOL isShowing;

@property (nonatomic , assign)CGPoint startPoint;

@property (nonatomic , assign)CGFloat zoomScale;

@property (nonatomic , assign)CGPoint startCenter;

@property (nonatomic , strong)NSMutableDictionary *loadingImageModelDic;
@property (nonatomic , strong)NSMutableDictionary *preloadingModelDic;
//GCD中的对象在6.0之前是不参与ARC的，而6.0之后 在ARC下使用GCD也不用关心释放问题
@property (strong, nonatomic) dispatch_queue_t preloadingQueue;

@end

@implementation LBScrollViewStatusModel

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.scale = @1;
        self.contentOffset = CGPointMake(0, 0);
    }
    return self;
}


- (void)loadImageWithCompletedBlock:(void (^)(LBScrollViewStatusModel *, UIImage *, NSData *, NSError *, BOOL, NSURL *))completedBlock {
    _loadImageCompletedBlock = completedBlock;
    [self loadImage];
}

- (void)loadImage {
    weak_self;
    if (self.opreation) {
        return;
    }
    //Code=-999 "已取消"
    self.opreation = [[SDWebImageManager sharedManager] loadImageWithURL:self.url options:0 progress:^(NSInteger receivedSize, NSInteger expectedSize, NSURL * _Nullable targetURL) {
        
//        LBPhotoBrowserLog(@"LBScrollViewStatusModel:( %d ) line %d log: %d -- %d",self.index,__LINE__,(int)receivedSize ,(int)expectedSize);
    } completed:^(UIImage * _Nullable image, NSData * _Nullable data, NSError * _Nullable error, SDImageCacheType cacheType, BOOL finished, NSURL * _Nullable imageURL) {
       __block UIImage *downloadedImage = image;
        dispatch_async(dispatch_get_main_queue(), ^{
            wself.opreation = nil;
            if (wself.loadImageCompletedBlock) {
                wself.loadImageCompletedBlock(wself, downloadedImage, data, error, finished, imageURL);
            }else {
                if (error) {
                    downloadedImage = [LBPhotoBrowserManager defaultManager].errorImage;
                    LBPhotoBrowserLog(@"%@",error);
                }
                wself.currentPageImage  = downloadedImage;
                if (downloadedImage.images.count > 0) {
                    wself.currentPageImage = [LBPhotoBrowserManager defaultManager].lowGifMemory ? downloadedImage : [UIImage sdOverdue_animatedGIFWithData:data];
                }
            }
        });
    }];
}

@end

@implementation LBPhotoCollectionViewCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.contentView.backgroundColor = [UIColor clearColor];
        [self createUI];
        UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didDoubleTap:)];
        doubleTap.numberOfTapsRequired = 2;
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTap:)];
        [self addGestureRecognizer:tap];
        [self addGestureRecognizer:doubleTap];
        [tap requireGestureRecognizerToFail:doubleTap];
    }
    return self;
}

- (void)createUI {
    LBZoomScrollView *zoomScrollView =[[LBZoomScrollView alloc]init];
    [self.contentView addSubview:zoomScrollView];
    _zoomScrollView = zoomScrollView;
}

- (void)setModel:(LBScrollViewStatusModel *)model {
    _model = model;
    _zoomScrollView.model = model;
}
- (void)startPopAnimationWithModel:(LBScrollViewStatusModel *)model completionBlock:(void(^)(void))completion {
    [_zoomScrollView startPopAnimationWithModel:model completionBlock:completion];
}

- (void)didTap:(UITapGestureRecognizer *)tap {
    CGPoint point = [tap locationInView:(UIView *)_zoomScrollView.imageView];
    [_zoomScrollView handlesingleTap:point];
}
- (void)didDoubleTap:(UITapGestureRecognizer *)tap {
    CGPoint point = [tap locationInView:(UIView *)_zoomScrollView.imageView];
    if (!CGRectContainsPoint(_zoomScrollView.imageView.bounds, point)) {
        return;
    }
    [_zoomScrollView handleDoubleTap:point];
}

@end

@implementation LBPhotoBrowserView

- (void)dealloc {
    [[NSNotificationCenter defaultCenter]removeObserver:self];
    SDDispatchQueueRelease(_preloadingQueue);
}

- (NSMutableArray *)models {
    if (!_models) {
        _models = [[NSMutableArray alloc]init];
    }
    return _models;
}
- (NSMutableDictionary *)preloadingModelDic {
    if (!_preloadingModelDic) {
        _preloadingModelDic = [[NSMutableDictionary alloc]init];
    }
    return _preloadingModelDic;
}

- (NSMutableDictionary *)loadingImageModelDic {
    if (!_loadingImageModelDic) {
        _loadingImageModelDic = [[NSMutableDictionary alloc]init];
    }
    return _loadingImageModelDic;
}

- (UIPageControl *)pageControl {
    if (!_pageControl) {
        UIPageControl *pageControl = [[UIPageControl alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 10)];
        pageControl.currentPageIndicatorTintColor = [UIColor whiteColor];
        pageControl.pageIndicatorTintColor = [UIColor grayColor];
        pageControl.numberOfPages = self.dataArr.count;
        pageControl.currentPage = [LBPhotoBrowserManager defaultManager].currentPage;
        [self addSubview:pageControl];
        _pageControl = pageControl;
    }
    return _pageControl;
}

- (UICollectionView *)collectionView {
    if (!_collectionView) {
        UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc]init];
        flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        flowLayout.minimumInteritemSpacing = 0;
        flowLayout.minimumLineSpacing = 0;
        // there page sapce is equal to 20
        UICollectionView *collectionView = [[UICollectionView alloc]initWithFrame:CGRectMake(-itemSpace / 2.0, 0, SCREEN_WIDTH + itemSpace, SCREEN_HEIGHT) collectionViewLayout:flowLayout];
        [self addSubview:collectionView];
        collectionView.delegate = self;
        collectionView.dataSource = self;
        collectionView.pagingEnabled = YES;
        collectionView.alwaysBounceVertical = NO;
        collectionView.showsHorizontalScrollIndicator = NO;
        collectionView.showsVerticalScrollIndicator = NO;
        collectionView.backgroundColor = [UIColor clearColor];
        [self collectionViewRegisterCellWithCollectionView:collectionView];
        _collectionView = collectionView;
    }
    return _collectionView;
}
- (void)collectionViewRegisterCellWithCollectionView:(UICollectionView *)collentionView {
    NSString *ID = NSStringFromClass([LBPhotoCollectionViewCell class]);
    [collentionView registerClass:[LBPhotoCollectionViewCell class] forCellWithReuseIdentifier:ID];
}


- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.windowLevel = UIWindowLevelAlert;
        self.hidden = NO;
        self.backgroundColor = [UIColor blackColor];
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(scrollViewDidScroll:) name:LBGifImageDownloadFinishedNot object:nil];
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(removePageControl) name:LBImageViewWillDismissNot object:nil];
        UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(didPan:)];
        [self addGestureRecognizer:pan];
        [LBPhotoBrowserManager defaultManager].currentCollectionView = self.collectionView;
        _preloadingQueue = dispatch_queue_create("lb.photoBrowser", DISPATCH_QUEUE_SERIAL);
        _isShowing = NO;
    }
    return self;
}

- (void)didPan:(UIPanGestureRecognizer *)pan {
    CGPoint location = [pan locationInView:self];
    CGPoint point = [pan translationInView:self];
    LBPhotoCollectionViewCell *cell = (LBPhotoCollectionViewCell *)[self.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForRow:self.pageControl.currentPage inSection:0]];
    switch (pan.state) {
        case UIGestureRecognizerStateBegan:
        {
            _startPoint = location;
            self.tag = 0;
            _zoomScale = cell.zoomScrollView.zoomScale;
            _startCenter = cell.zoomScrollView.imageView.center;
        }
            break;
        case UIGestureRecognizerStateChanged:
        {
            if (location.y - _startPoint.y < 0 && self.tag == 0) {
                return;
            }
            cell.zoomScrollView.imageViewIsMoving = YES;
            double percent = 1 - fabs(point.y) / self.frame.size.height;// 移动距离 / 整个屏幕
            double scalePercent = MAX(percent, 0.3);
            if (location.y - _startPoint.y < 0) {
                scalePercent = 1.0 * _zoomScale;
            }else {
                scalePercent = _zoomScale * scalePercent;
            }
            CGAffineTransform scale = CGAffineTransformMakeScale(scalePercent, scalePercent);
            cell.zoomScrollView.imageView.transform = scale;
            cell.zoomScrollView.imageView.center = CGPointMake(self.startCenter.x + point.x, self.startCenter.y + point.y);
            self.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:scalePercent / _zoomScale];
            self.tag = 1;
        }
            break;
        case UIGestureRecognizerStateEnded:
        case UIGestureRecognizerStateCancelled: {
            if (point.y > 100 ) {
                [self dismissFromCell:cell];
            }else {
                [self cancelFromCell:cell];
            }
        }
            break;
            
        default:
            break;
    }
}

- (void)dismissFromCell:(LBPhotoCollectionViewCell *)cell {
    [cell.zoomScrollView handlesingleTap:CGPointZero];
}

- (void)cancelFromCell:(LBPhotoCollectionViewCell *)cell {
    weak_self;
    CGAffineTransform scale = CGAffineTransformMakeScale(_zoomScale , _zoomScale);
    [UIView animateWithDuration:0.25 animations:^{
        cell.zoomScrollView.imageView.transform = scale;
        wself.backgroundColor = [UIColor blackColor];
        cell.zoomScrollView.imageView.center = wself.startCenter;
    }completion:^(BOOL finished) {
        cell.zoomScrollView.imageViewIsMoving = NO;
        [cell.zoomScrollView layoutSubviews];

    }];
}

#pragma mark - 监听通知

- (void)removePageControl {
    [UIView animateWithDuration:0.25 animations:^{
        self.pageControl.alpha = 0;
    }completion:^(BOOL finished) {
        [self.pageControl removeFromSuperview];
    }];
    if (![LBPhotoBrowserManager defaultManager].needPreloading) {
        return;
    }
    [self.loadingImageModelDic.allValues enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        LBScrollViewStatusModel *model = (LBScrollViewStatusModel *)obj;
        if (model.opreation) {
            [model.opreation cancel];
        }
    }];
}

- (void)showImageViewsWithURLs:(LBUrlsMutableArray *)urls andSelectedIndex:(int)index{
    _dataArr = urls;
    if (_pageControl) {
        [_pageControl removeFromSuperview];
    }
    self.pageControl.bottom = SCREEN_HEIGHT - 50;
    self.pageControl.hidden = urls.count == 1? YES:NO;
    [self.models removeAllObjects];
    for (int i = 0 ; i < _dataArr.count; i++) {
        LBScrollViewStatusModel *model = [[LBScrollViewStatusModel alloc]init];
        model.showPopAnimation = i == index ? YES:NO;
        model.isShowing = i == index ? YES:NO;
        model.url = _dataArr[i];
        model.index = i;
        [self.models addObject:model];
    }
    self.collectionView.alwaysBounceHorizontal = urls.count == 1? NO : YES;
    [self.collectionView reloadData];
    [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:index inSection:0] atScrollPosition:UICollectionViewScrollPositionNone animated:NO];
}

- (void)showImageViewsWithImages:(LBImagesMutableArray *)images andSeletedIndex:(int)index {
    _dataArr = images;
    if (_pageControl) {
        [_pageControl removeFromSuperview];
    }
    self.pageControl.bottom = SCREEN_HEIGHT - 50;
    self.pageControl.hidden = images.count == 1? YES:NO;
    [self.models removeAllObjects];
    for (int i = 0 ; i < images.count; i++) {
        LBScrollViewStatusModel *model = [[LBScrollViewStatusModel alloc]init];
        model.showPopAnimation = i == index ? YES:NO;
        model.isShowing = i == index ? YES:NO;
        model.currentPageImage = images[i];
        model.index = i;
        [self.models addObject:model];
    }
    self.collectionView.alwaysBounceHorizontal = images.count == 1? NO : YES;
    [self.collectionView reloadData];
    [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:index inSection:0] atScrollPosition:UICollectionViewScrollPositionNone animated:NO];
}

#pragma mark - collectionView的数据源&代理

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    if (_dataArr) {
        return _dataArr.count;
    }
    return 0;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    NSString *ID = NSStringFromClass([LBPhotoCollectionViewCell class]);
    LBPhotoCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:ID forIndexPath:indexPath];
    return cell;
}
#pragma mark - 代理方法

// 新版的SDWebImage不知支持Gif 故采用了老版Gif的方式 但是这样加载太多Gif内存容易升高 在收到内存警告的时候 可以通过这个来清理内存 [[SDImageCache sharedImageCache] clearMemory];

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake(SCREEN_WIDTH + itemSpace, SCREEN_HEIGHT);
}


- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
    weak_self;
    LBPhotoCollectionViewCell *currentCell = (LBPhotoCollectionViewCell *)cell;
    LBScrollViewStatusModel *model = self.models[indexPath.item];
    model.currentPageImage = model.currentPageImage ?:[self getCacheImageForModel:model];
    // 需要展示动画的话 展示动画
    if (model.showPopAnimation) {
        [currentCell startPopAnimationWithModel:model completionBlock:^{
            wself.isShowing = YES;
            model.showPopAnimation = NO;
            [wself collectionView:collectionView willDisplayCell:cell forItemAtIndexPath:indexPath];
        }];
    }
    if (_isShowing == NO) return;
    currentCell.model = model;
    if (model.currentPageImage && model.currentPageImage.images.count >0) {
        [self scrollViewDidScroll:collectionView];
    }
    if ([self.dataArr.firstObject isKindOfClass:[UIImage class]]) return;
    
    if (![LBPhotoBrowserManager defaultManager].needPreloading) return;
    
    dispatch_async(wself.preloadingQueue, ^{
        int leftCellIndex = model.index - 1 >= 0 ?model.index - 1:0;
        int rightCellIndex = model.index + 1 < wself.models.count? model.index + 1 : (int)wself.models.count -1;
        //wself.loadingImageModels 新计算出的需要加载的 -- > 如果个原来的没有重合的 --> 取消
        [wself.preloadingModelDic removeAllObjects];
        NSMutableDictionary *indexDic = wself.preloadingModelDic; // 采用全局的字典 减少快速切换时 重复创建消耗性能的问题
        indexDic[[NSString stringWithFormat:@"%d",leftCellIndex]] = @1;
        indexDic[[NSString stringWithFormat:@"%d",model.index]] = @1;
        indexDic[[NSString stringWithFormat:@"%d",rightCellIndex]] = @1;

        for (NSString *indexStr in wself.loadingImageModelDic.allKeys) {
            if (indexDic[indexStr]) continue;
            LBScrollViewStatusModel *loadingModel = wself.loadingImageModelDic[indexStr];
            if (loadingModel.opreation) {
                [loadingModel.opreation cancel];
                loadingModel.opreation = nil;
            }
        }
        [wself.loadingImageModelDic removeAllObjects];
        for (int i = leftCellIndex; i <= rightCellIndex; i++) {
            LBScrollViewStatusModel *loadingModel = wself.models[i];
            NSString *indexStr = [NSString stringWithFormat:@"%d",i];
            wself.loadingImageModelDic[indexStr] = loadingModel;
            if (model.index == i) continue;
            LBScrollViewStatusModel *preloadingModel = wself.models[i];
            preloadingModel.currentPageImage = preloadingModel.currentPageImage ?:[wself getCacheImageForModel:preloadingModel];
            if (preloadingModel.currentPageImage) continue;
            [preloadingModel loadImage];
        }
    });

}


#pragma mark - 处理cell中图片的显示

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGFloat pageWidth = self.collectionView.width;
    int page = floor((self.collectionView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
    [self refreshStatusWithPage:page];
    self.pageControl.currentPage = page;
    [LBPhotoBrowserManager defaultManager].currentPage = page;
    LBPhotoCollectionViewCell *cell = (LBPhotoCollectionViewCell *)[self.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForRow:page inSection:0]];
    if (![scrollView isKindOfClass:[UIScrollView class]]) {
        LBPhotoBrowserManager.defaultManager.currentShowImageView = nil;
    }
    LBPhotoBrowserManager.defaultManager.currentShowImageView = cell.zoomScrollView.imageView;
}

- (void)refreshStatusWithPage:(int)page {
    if (page == self.pageControl.currentPage ) {
        return;
    }
    [self changeModelOfCellInRow:page];
    
}

#pragma mark - 获取URL的缓存图片

- (UIImage *)getCacheImageForModel:(LBScrollViewStatusModel *)model {
    __block UIImage *localImage = nil;
    LBPhotoBrowserManager *mgr = [LBPhotoBrowserManager defaultManager];
    NSString *address = model.url.absoluteString;
    localImage =  [[SDImageCache sharedImageCache] imageFromCacheForKey:address];
    
    if (localImage && localImage.images.count > 0) {//gif 图片
        if (mgr.lowGifMemory == YES) {
            return localImage;
        }else{
            [[SDImageCache sharedImageCache] queryCacheOperationForKey: model.url.absoluteString done:^(UIImage * _Nullable image, NSData * _Nullable data, SDImageCacheType cacheType) {
                localImage = [UIImage sdOverdue_animatedGIFWithData:data];
            }];
            return localImage;
        }
    }else if (localImage) { // 图片存在
        return localImage;
    }
    return nil;
}

#pragma mark - 修改cell子控件的状态 的状态

- (void)changeModelOfCellInRow:(int)row {
    for (LBScrollViewStatusModel *model in self.models) {
        model.isShowing = NO;
    }
    if (row >= 0 && row < self.models.count) {
        LBScrollViewStatusModel *model = self.models[row];
        model.isShowing = YES;
    }
}
@end

