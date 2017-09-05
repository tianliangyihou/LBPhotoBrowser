# LBPhotoBrowser

一行代码即可搞定下面效果的浏览器.  简书地址:[http://www.jianshu.com/p/cf72690b46a8](http://www.jianshu.com/p/cf72690b46a8)(详细说明)

LBPhotoBrowser对gif的播放提供了两种方式(详细见简书):

(1)采用系统的 + (nullableUIImage*)animatedImageWithImages:(NSArray *)images duration:(NSTimeInterval)durationNS_AVAILABLE_IOS(5_0);

(2)自定义gif的播放:获取gif的每帧图片和播放时间,通过CADisplayLink(低内存)播放.demo中加载的gif包含了144张图,仍然保持较低内存,借鉴了YYImage的播放方式

通过`LBPhotoBrowserManager`的`lowGifMemory`属性控制.

效果图如下: 

![](http://upload-images.jianshu.io/upload_images/2306467-4edb6c8abedd9d34.gif?imageMogr2/auto-orient/strip)


# 使用(usage)

实现上面的效果,只需调用下面这行代码:
```obj-c

/**
 展示图片
 @param urls 需要加载的图片的URL数组
 @param imageViews 传入需要大图显示的imageViews 因为将来需要在对应的地方imageView用动画消除掉,主要是取imageView的frame
 @param index 点击图片的index
 @param superView 当前View的父View
 */
- (void)showImageWithURLArray:(NSArray *)urls fromImageViews:(NSArray *)imageViews andSelectedIndex:(int)index andImageViewSuperView:(UIView *)superView;

Example:

   [[LBPhotoBrowserManager defaultManager] showImageWithURLArray:_urls fromImageViews: _imageViews andSelectedIndex:(int)tap.view.tag andImageViewSuperView:self.view];
   
 ```
如果需要添加长按手势,可以采用默认的(类似微信的)

```obj-c

// 添加默认的长按控件
- (instancetype)addLongPressShowTitles:(NSArray <NSString *>*)titles;
// 默认长按控件的回调
- (instancetype)addTitleClickCallbackBlock:(void(^)(UIImage *image,NSIndexPath *indexPath,NSString *title))titleClickCallBackBlock;

Example:
// 添加长按手势的效果 
    [[[LBPhotoBrowserManager defaultManager] addLongPressShowTitles:self.titles] addTitleClickCallbackBlock:^(UIImage *image, NSIndexPath *indexPath, NSString *title) {
        LBPhotoBrowserLog(@"%@ %@ %@",image,indexPath,title);
    }]
   
 ```
 如果需要自定义长按手势的弹出框,实现下面这个Bock即可
 ```obj-c
// 添加自定义的长按控件
- (instancetype)addLongPressCustomViewBlock:(UIView *(^)(UIImage *image, NSIndexPath *indexPath))longPressBlock;
 ```
 
 如果需要自定义每张图片加载的占位图,实现下面这个Block,否则采用默认的站位图LBLoading.png
  ```obj-c
// 为每张图片添加占位图
- (instancetype)addPlaceHoldImageCallBackBlock:(UIImage *(^)(NSIndexPath * indexPath))placeHoldImageCallBackBlock;

Example:
     // 给每张图片添加占位图
    [[LBPhotoBrowserManager defaultManager] addPlaceHoldImageCallBackBlock:^UIImage *(NSIndexPath *indexPath) {
        LBPhotoBrowserLog(@"%@",indexPath);
        return [UIImage imageNamed:@"LBLoading.png"];
    }];
 ```
 
 有时候你也可以这么写:
 ```obj-c
   
  [[[[LBPhotoBrowserManager defaultManager] addLongPressShowTitles:self.titles] addTitleClickCallbackBlock:^(UIImage *image, NSIndexPath *indexPath, NSString *title) {
        LBPhotoBrowserLog(@"%@ %@ %@",image,indexPath,title);
    }]addPlaceHoldImageCallBackBlock:^UIImage *(NSIndexPath *indexPath) {
        return [UIImage imageNamed:@"LBLoading.png"];
    }].lowGifMemory = YES;
 
```

除此之外:LBPhotoBrowser对图片放大到超过屏幕尺寸时候 拖动的消失方式,也提供了两种方式`LBMaximalImageViewOnDragDismmissStyle`默认的`LBMaximalImageViewOnDragDismmissStyleOne`

