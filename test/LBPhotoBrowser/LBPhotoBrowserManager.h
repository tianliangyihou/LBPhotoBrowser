//
//  LBPhotoBrowseManager.h
//  test
//
//  Created by dengweihao on 2017/8/1.
//  Copyright © 2017年 llb. All rights reserved.
//
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#import "LBPhotoBrowserConst.h"
#import "LBPhotoBrowserView.h"

/**
                            控件的基本结构
 
 |-------------------------LBTapDetectingImageView------------------------| (最上层)
 
 |-------------------------LBZoomScrollView------------------------|

 |-------------------------UICollectionViewCell------------------------|
 
 |-------------------------UICollectionView------------------------|
 
 |-------------------------LBPhotoBrowseView------------------------|       (最下层)

 */
/**
  iphone X 适配
*/
@interface LBPhotoWebItem : NSObject
@property (nonatomic , strong)NSString *urlString;
@property (nonatomic , assign)CGRect frame;
@property (nonatomic , assign)CGSize placeholdSize;
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

@end



@interface LBPhotoBrowserManager : NSObject
// 当前展示的urls
@property (nonatomic , strong, readonly)LBUrlsMutableArray *urls;

// 传入的imageViews
@property (nonatomic , strong, readonly)LBFramesMutableArray *frames;

// 传入的imageViews
@property (nonatomic , strong, readonly)LBImagesMutableArray *images;

// 用来展示图片的UI控件
@property (nonatomic , weak, readonly)LBPhotoBrowserView *photoBrowserView;

// 传入的imageViews的共同父View
@property (nonatomic , weak, readonly)UIView *imageViewSuperView;

// 当前选中的页
@property (nonatomic , assign)NSInteger currentPage;

// 展示图片使用collectionView来提高效率
@property (nonatomic , weak)UICollectionView *currentCollectionView;

//当图片加载出现错误时候显示的图片 if nil default is [UIImage imageNamed:@"LBLoadError.jpg"]
@property (nonatomic , strong)UIImage *errorImage;

// 每张正在加载的图片的站位图
@property (nonatomic , copy ,readonly)UIImage *(^placeholdImageCallBackBlock)(NSIndexPath *indexPath);

@property (nonatomic , copy ,readonly)CGSize (^placeholdImageSizeBlock)(UIImage *Image,NSIndexPath *indexpath);

// 开启这个选项后 在加载gif的时候 会大大的降低内存.与YYImage对gif的内存优化思路一样 default is NO
@property (nonatomic , assign)BOOL lowGifMemory;

// 当前图片浏览器正在展示的imageView
@property (nonatomic , strong)UIImageView *currentShowImageView;

// 第一次展示图片浏览器的时候 是否需要动画 3Dtouch进入不需要展示 default is YES
@property (nonatomic , assign)BOOL showBrowserWithAnimation;

// 当图片浏览器将要消失的时候 是否停止所有下载 default is YES
@property (nonatomic , assign)BOOL cancelLoadImageWhenRemove;

/**
 返回当前的一个单例(不完全单利)
 */
+ (instancetype)defaultManager;

- (instancetype)showImageWithLocalItems:(NSArray <LBPhotoLocalItem *> *)items selectedIndex:(NSInteger)index fromImageViewSuperView:(UIView *)superView;

- (instancetype)showImageWithWebItems:(NSArray <LBPhotoWebItem *> *)items selectedIndex:(NSInteger)index fromImageViewSuperView:(UIView *)superView;

- (instancetype)showImageWithURLArray:(NSArray *)urls fromImageViewFrames:(NSArray *)frames selectedIndex:(NSInteger)index imageViewSuperView:(UIView *)superView;

#pragma mark - 自定义图片长按按钮的Block 类似TableViewCell的代理
// 添加默认的长按控件
- (instancetype)addLongPressShowTitles:(NSArray <NSString *>*)titles;
// 默认长按控件的回调
- (instancetype)addTitleClickCallbackBlock:(void(^)(UIImage *image,NSIndexPath *indexPath,NSString *title))titleClickCallBackBlock;
// 添加自定义的长按控件
- (instancetype)addLongPressCustomViewBlock:(UIView *(^)(UIImage *image, NSIndexPath *indexPath))longPressBlock;
// 为每张图片添加占位图 defaut ->LBLoading.png
- (instancetype)addPlaceholdImageCallBackBlock:(UIImage *(^)(NSIndexPath *indexPath))placeholdImageCallBackBlock;
// 为每张站位图 设置大小
- (instancetype)addPlaceholdImageSizeBlock:(CGSize (^)(UIImage *Image,NSIndexPath *indexpath))placeholdImageSizeBlock;

// 图片浏览器将要消失的Block
- (instancetype)addPhotoBrowserWillDismissBlock:(void(^)(void))dismissBlock;

- (instancetype)addPhotoBrowserDidDismissBlock:(void(^)(void))dismissBlock;


- (NSArray<NSString *> *)currentTitles;

- (void (^)(UIImage *, NSIndexPath *, NSString *))titleClickBlock;

- (UIView *(^)(UIImage *,NSIndexPath *))longPressCustomViewBlock;

@end
