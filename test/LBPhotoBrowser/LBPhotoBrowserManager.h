//
//  LBPhotoBrowseManager.h
//  test
//
//  Created by dengweihao on 2017/8/1.
//  Copyright © 2017年 llb. All rights reserved.
//
#import <UIKit/UIKit.h>
#import "LBPhotoBrowserConst.h"
#import "LBPhotoBrowserView.h"

/**
 ---> 是否增加 addViewBlock 自定义显示底部内容
 --->  添加source view不同父View跳转
 --->  添加 pageController 是否需要变化情况
 --->  播放本地Gif图片
 --->  同一个URL的预加载机制
 --->  大于10张图片的优化
 --->  gif的播放
 --->  GPU,CPU的性能测试
 */
/**
                            控件的基本结构
 |-------------------------LBTapDetectingImageView------------------------| (最上层)
 
 |-------------------------LBZoomScrollView------------------------|

 |-------------------------UICollectionViewCell------------------------|
 
 |-------------------------UICollectionView------------------------|
 
 |-------------------------LBPhotoBrowseView------------------------|       (最下层)
 */

@interface LBPhotoWebItem : NSObject
// 加载图片的url
@property (nonatomic , copy)NSString *urlString;
//imageView的frame
@property (nonatomic , assign)CGRect frame;
//站位图的大小
@property (nonatomic , assign)CGSize placeholdSize;
//占位图片  default is [UIImage imageNamed:@"LBLoading.png"]
@property (nonatomic , strong)UIImage *placeholdImage;
- (instancetype)initWithURLString:(NSString *)url frame:(CGRect)frame;
- (instancetype)initWithURLString:(NSString *)url frame:(CGRect)frame placeholdImage:(UIImage *)image;
- (instancetype)initWithURLString:(NSString *)url frame:(CGRect)frame placeholdSize:(CGSize)size;
- (instancetype)initWithURLString:(NSString *)url frame:(CGRect)frame placeholdImage:(UIImage *)image placeholdSize:(CGSize)size;
@end

@interface LBPhotoLocalItem : NSObject
@property (nonatomic , strong)UIImage *localImage;
@property (nonatomic , assign)CGRect frame;

- (instancetype)initWithImage:(UIImage *)image frame:(CGRect)frame;
- (instancetype)initWithImage:(UIImage *)image frame:(CGRect)frame gifData:(NSData *)gifData;
@end


@interface LBPhotoBrowserManager : NSObject

// 传入的urls
@property (nonatomic , strong, readonly)LBUrlsMutableArray *urls;

// 传入的imageView的frames
@property (nonatomic , strong, readonly)LBFramesMutableArray *frames;

//传入的本地图片
@property (nonatomic , strong, readonly)LBImagesMutableArray *images;

// 关于联动的信息
@property (nonatomic , strong, readonly)NSMutableDictionary *linkageInfo;

// 用来展示图片的UI控件
@property (nonatomic , strong, readonly)LBPhotoBrowserView *photoBrowserView;

// 传入的imageView的共同父View
@property (nonatomic , weak, readonly)UIView *imageViewSuperView;

// 当前选中的页
@property (nonatomic , assign)NSInteger currentPage;

// 展示图片使用collectionView来提高效率
@property (nonatomic , weak)UICollectionView *currentCollectionView;

// 导航条
@property (nonatomic , weak)UIView *navigationBar;

//当图片加载出现错误时候显示的图片  default is [UIImage imageNamed:@"LBLoadError.png"]
//如果LBLoadError.png这张图片不满意 可以修改这个属性替换
@property (nonatomic , strong)UIImage *errorImage;

// 每张正在加载的图片的占位图
@property (nonatomic , copy ,readonly)UIImage *(^placeholdImageCallBackBlock)(NSIndexPath *indexPath);

// 每张正在加载的图片的站位图的大小
@property (nonatomic , copy ,readonly)CGSize (^placeholdImageSizeBlock)(UIImage *Image,NSIndexPath *indexpath);

// 当前图片浏览器正在展示的imageView
@property (nonatomic , strong)UIImageView *currentDisplayImageView;

// 当前图片浏览器正在展示的imageView的model
@property (nonatomic , strong)LBScrollViewStatusModel *currentDisplayModel;

/**
 是否需要预加载 default is YES
 每次LBPhotoBrowser -> did dismiss(消失)的时候,LBPhotoBrowserManager 会将 needPreloading 置为YES,
 故:如果需要修改该选项 需要每次弹出LBPhotoBrowser的时候 将needPreloading 置为 NO;
 */
@property (nonatomic , assign)BOOL needPreloading;

/**
 开启这个选项后 在加载gif的时候 会大大的降低内存.与YYImage对gif的内存优化思路一样 default is NO
 每次LBPhotoBrowser -> did dismiss(消失)的时候,LBPhotoBrowserManager 会将 lowGifMemory 置为NO,
 故:如果需要修改该选项 需要每次弹出LBPhotoBrowser的时候 将lowGifMemory 置为 YES;
 */
@property (nonatomic , assign)BOOL lowGifMemory;

/**
  开启这个选项后 展示过的图片就会被销毁 等到需要展示的时候再去加载 对本地图片无效
 */
@property (nonatomic , assign)BOOL destroyImageNotNeedShow;

/**
 含有图片的bundle
 */
@property (nonatomic , strong, readonly)NSBundle *lb_resourceBundle;

/**
 返回当前的一个单例(不完全单利)
 */
+ (instancetype)defaultManager;

/**
 展示本地图片
 @param items 传入本地的图片模型数组
 @param index 当前选中图片的下标
 @param superView 传入的控件的父View
 @return 返回当前对象
 */
- (instancetype)showImageWithLocalItems:(NSArray <LBPhotoLocalItem *> *)items selectedIndex:(NSInteger)index fromImageViewSuperView:(UIView *)superView;

/**
 展示网络图片
 @param items 传入网络的图片模型数组
 @param index 当前选中图片的下标
 @param superView 传入的控件的父View
 @return 返回当前对象
 */
- (instancetype)showImageWithWebItems:(NSArray <LBPhotoWebItem *> *)items selectedIndex:(NSInteger)index fromImageViewSuperView:(UIView *)superView;

/**
 展示网络图片
 上面的方法是对这个方法的进一步封装
 @param urls 传入的urls数组  字符串 或者 url都可以
 @param frames 传入的控件的frames
 @param index 当前选中图片的下标
 @param superView 传入的控件的父View
 @return 返回当前对象
 */
- (instancetype)showImageWithURLArray:(NSArray *)urls fromImageViewFrames:(NSArray *)frames selectedIndex:(NSInteger)index imageViewSuperView:(UIView *)superView;


#pragma mark - 回调
// 添加默认的长按控件
- (instancetype)addLongPressShowTitles:(NSArray <NSString *>*)titles;

// 默认长按控件的回调
- (instancetype)addTitleClickCallbackBlock:(void(^)(UIImage *image,NSIndexPath *indexPath,NSString *title,BOOL isGif,NSData *gifImageData))titleClickCallBackBlock;

// 添加自定义的长按控件
- (instancetype)addLongPressCustomViewBlock:(UIView *(^)(UIImage *image, NSIndexPath *indexPath))longPressBlock;

// 为每张图片添加占位图 defaut ->LBLoading.png 如果通过LBPhotoWebItem设置placeholdImage后,不需要实现
- (instancetype)addPlaceholdImageCallBackBlock:(UIImage *(^)(NSIndexPath *indexPath))placeholdImageCallBackBlock;

// 为每张占位图 设置大小 如果配置过LBPhotoWebItem后,如果通过LBPhotoWebItem设置placeholdSize后,不需要实现
- (instancetype)addPlaceholdImageSizeBlock:(CGSize (^)(UIImage *Image,NSIndexPath *indexpath))placeholdImageSizeBlock;

// 图片浏览器将要消失的回调
- (instancetype)addPhotoBrowserWillDismissBlock:(void(^)(void))dismissBlock;

// 图片浏览器彻底消失的回调
- (instancetype)addPhotoBrowserDidDismissBlock:(void(^)(void))dismissBlock;

// 关联collectionView
- (instancetype)addCollectionViewLinkageStyle:(UICollectionViewScrollPosition)style cellReuseIdentifier:(NSString *)reuseIdentifier;

// 移除图片
- (instancetype)addPhotoBrowserDeleteItemBlock:(void(^)(NSIndexPath *deleIndexPath,UIImage *image))deleteBlock;
#pragma mark - get方法

- (NSArray<NSString *> *)currentTitles;

- (void (^)(UIImage *,NSIndexPath *,NSString *,BOOL,NSData *))titleClickBlock;

- (UIView *(^)(UIImage *,NSIndexPath *))longPressCustomViewBlock;

- (void (^)(NSIndexPath *, UIImage *))deleteItemBlock;
@end
