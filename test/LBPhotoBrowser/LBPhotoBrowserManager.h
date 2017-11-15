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
#import "LBPhotoBrowserShowHelper.h"

/**
                            控件的基本结构
 
 |-------------------------LBTapDetectingImageView------------------------| (最上层)
 
 |-------------------------LBZoomScrollView------------------------|

 |-------------------------UICollectionViewCell------------------------|
 
 |-------------------------UICollectionView------------------------|
 
 |-------------------------LBPhotoBrowseView------------------------|       (最下层)

 */
/**
   一行代码搞定类似微信的图片浏览(支持gif)
 */
typedef NS_ENUM(NSInteger, LBMaximalImageViewOnDragDismmissStyle) {
    LBMaximalImageViewOnDragDismmissStyleOne,// 类似微信的动画
    LBMaximalImageViewOnDragDismmissStyleTwo // 自定义的动画
};

@interface LBPhotoBrowserManager : NSObject

// 当前展示的urls
@property (nonatomic , strong, readonly)LBUrlsMutableArray *urls;

// 传入的imageViews
@property (nonatomic , strong, readonly)LBImageViewsArray *imageViews;

//工具类 可以通过helper.scrollPosition 来改变photoBrowser和用户collectionView的联动方式
@property (nonatomic , strong)LBPhotoBrowserShowHelper *helper;

// 用来展示图片的UI控件
@property (nonatomic , weak, readonly)LBPhotoBrowserView *photoBrowserView;

// 传入的imageViews的共同父View
@property (nonatomic , weak, readonly)UIView *imageViewSuperView;

// 传入的点击imageview的index
@property (nonatomic , assign)int selectedIndex;

// 展示图片使用collectionView来提高效率
@property (nonatomic , weak)UICollectionView *currentCollectionView;

//是否需要弹性效果 default = YES
@property (nonatomic , assign)BOOL isNeedBounces;

//当图片加载出现错误时候显示的图片 if nil default is [UIImage imageNamed:@"LBLoadError.jpg"]
@property (nonatomic , strong)UIImage *errorImage;

// 每张正在加载的图片的站位图
@property (nonatomic , copy ,readonly)UIImage *(^placeHoldImageCallBackBlock)(NSIndexPath *indexPath);

// 当图片放大到超过屏幕尺寸时候 拖动的消失方式 Default is LBMaximalImageViewOnDragDismmissStyleOne
@property (nonatomic , assign)LBMaximalImageViewOnDragDismmissStyle style;

// 开启这个选项后 在加载gif的时候 会大大的降低内存.与YYImage对gif的内存优化思路一样 default is NO
@property (nonatomic , assign)BOOL lowGifMemory;

// 当前图片浏览器正在展示的imageView
@property (nonatomic , strong)UIImageView *currentShowImageView;

// 第一次展示图片浏览器的时候 是否需要动画 3Dtouch进入不需要展示 default is YES
@property (nonatomic , assign)BOOL showBrowserWithAnimation;

/**
 返回当前的一个单例(不完全单利)
 */
+ (instancetype)defaultManager;

/**
 展示 网络图片or本地图片
 @param urls 需要加载的图片的URL数组
 @param imageViews 传入需要大图显示的imageViews 因为将来需要在对应的地方imageView用动画消除掉,主要是取imageView的frame
 @param index 点击图片的index
 @param superView 当前View的父View
 */
- (void)showImageWithURLArray:(NSArray *)urls fromImageViews:(NSArray *)imageViews selectedIndex:(int)index imageViewSuperView:(UIView *)superView;
/**
 展示 网络图片or本地图片
 @param urls 需要加载的图片的URL数组
 @param index 点击图片的index
 @param collectionView 需要展示图片的collectionView
 */
- (void)showImageWithURLArray:(NSArray *)urls fromCollectionView:(UICollectionView *)collectionView selectedIndex:(int)index;

/**
 展示 网络图片or本地图片
 @param urls 需要加载的图片的URL数组
 @param collectionView 需要展示图片的collectionView
 @param index 点击图片的index
 @param unwantedUrls 不需要展示的url
 */
- (void)showImageWithURLArray:(NSArray *)urls fromCollectionView:(UICollectionView *)collectionView selectedIndex:(int)index unwantedUrls:(NSArray *)unwantedUrls;


#pragma mark - 自定义图片长按按钮的Block 类似TableViewCell的代理
// 添加默认的长按控件
- (instancetype)addLongPressShowTitles:(NSArray <NSString *>*)titles;
// 默认长按控件的回调
- (instancetype)addTitleClickCallbackBlock:(void(^)(UIImage *image,NSIndexPath *indexPath,NSString *title))titleClickCallBackBlock;
// 添加自定义的长按控件
- (instancetype)addLongPressCustomViewBlock:(UIView *(^)(UIImage *image, NSIndexPath *indexPath))longPressBlock;
// 为每张图片添加占位图 defaut ->LBLoading.png
- (instancetype)addPlaceHoldImageCallBackBlock:(UIImage *(^)(NSIndexPath * indexPath))placeHoldImageCallBackBlock;
// 图片浏览器将要消失的Block
- (instancetype)addPhotoBrowserWillDismissBlock:(void(^)(void))dismissBlock;

- (NSArray<NSString *> *)currentTitles;

- (void (^)(UIImage *, NSIndexPath *, NSString *))titleClickBlock;

- (UIView *(^)(UIImage *,NSIndexPath *))longPressCustomViewBlock;

@end
