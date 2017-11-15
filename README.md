# LBPhotoBrowser

一行代码即可搞定下面效果的浏览器.  简书地址:[http://www.jianshu.com/p/00f4b7b20dc4](http://www.jianshu.com/p/00f4b7b20dc4)(详细说明)

# 问题收集

这是目前的第三个版本了,如果你用的时候遇到什么问题(及时保存log)或者有什么建议的话,及时issues me,或者简书下面给我留言.

同时也非常感谢一些提出好的建议的人: KevinCheinCoder,simpleIsGod ,Ryan0520,cowboyfzl等

期望和你一同改进这个库.

```
LBPhotoBrowser对gif的播放提供了两种方式(详细见简书):

(1)采用系统的 + (nullableUIImage*)animatedImageWithImages:(NSArray *)images duration:(NSTimeInterval)durationNS_AVAILABLE_IOS(5_0);

(2)自定义gif的播放,具体步骤如下：

   * 获取当前手机可以利用的内存和当前展示的gif图片每帧图片加载到内存占用的大小,以取得当前内存可以加载gif的最大帧数.
     最大加载帧数 = 可利用内存 /  每帧图片的大小.
     
   * 使用CADisplayLink作为定时器,开始展示当前帧的图片
   
   * 获取当前帧的展示时间,展示完毕,切换下一帧图片.当在展示当前帧的图片的时候, 异步线程(自定义NSOperation)去取下一帧的图片,以供当前帧的图片展示
     完毕后,直接从缓存的buffer（字典）中读取.
     
   * 当gif图片的帧数大于当前内存适合加载的帧数的时候,buffer(字典)会不断的移除已展示过的图片,来确保加载到内存中的图片数稳定.
     如果小于可加载的最大帧数,直接全部加载到内存,节省CPU.
     
   * LBPhotoBrowser为了保证较低的CPU消耗,即使在图片浏览器加载多张gif的时候,也会保证同一时间内,只会对一张gif进行处理,不会同时去解压多张gif图片.
   
     demo中（采用方式2）加载的gif包含了144张图,仍然保持较低内存和cpu,借鉴了YYImage的播放方式
```
通过`LBPhotoBrowserManager`的`lowGifMemory`属性控制.
```objc

支持3Dtouch预览图片和进行操作

对3Dtouch的API进行了进一步的封装,使用起来更加简单,只需关心自己的业务逻辑即可

详细见下面

```
```objc
支持通过 [NSURL fileURLWithPath:@"xxx.path"]获取的图片

NSString *path = [[NSBundle mainBundle] pathForResource:@"timg.gif" ofType:nil];

通过在这种方式无法获取Assets.xcassets里面图片的路径 ---> 获取到的是nil

xcode9中 有时你通过这种方式也无法获取其他文件夹中的图片, 这时在项目的Build Phases中的 copy bundle resources 中添加该图片即可
```

新增collectionView图片的展示

```objc
 当你需要通过LBPhotoBrowser直接展示collectionView的图片,并且实现和你的collectionView联动的时候,调用下面方法
 
 /**
 展示 网络图片or本地图片
 @param urls 需要加载的图片的URL数组
 @param collectionView 需要展示图片的collectionView
 @param index 点击图片的index
 @param unwantedUrls 不需要展示的url
 */
- (void)showImageWithURLArray:(NSArray *)urls fromCollectionView:(UICollectionView *)collectionView selectedIndex:(int)index unwantedUrls:(NSArray *)unwantedUrls;


/**
 展示 网络图片or本地图片
 @param urls 需要加载的图片的URL数组
 @param index 点击图片的index
 @param collectionView 需要展示图片的collectionView
 */
- (void)showImageWithURLArray:(NSArray *)urls fromCollectionView:(UICollectionView *)collectionView selectedIndex:(int)index;

```

```objc
关于SDWebImage加载gif图片的问题(sd_setImageWithURL):

当你在真机上运行当前版本的时候,你会发现展示gif的一个问题 => 拖动pop当前界面的时候,imageView上的图片不见了

这个是SDWebImage内部的一个方法导致的,你可以在demo中找到原因和解决办法

```

效果图如下:

最新版V1.2:

![](https://github.com/tianliangyihou/zhuxian/blob/master/20171114.gif?raw=true)

V1.1

![](https://github.com/tianliangyihou/zhuxian/blob/master/test.gif?raw=true)

v1.0

![](https://github.com/tianliangyihou/zhuxian/blob/master/2306467-14a8a6771dad3b5c.gif?raw=true)

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

#3DTouch功能

3DTouch功能的实现,采用了代理模式 即3步

1 注册代理 

2 遵守协议 

3 实现代理方法

 ```obj-c
 LBPhotoBrowser默认不支持3Dtouch功能,如果需要添加3DTouch功能 则需要给需要添加3Dtouch的控制器`#import "LB3DTouchVC.h"  
 
1 实现下面这个方法(注册代理)
 - (void)lb_registerForPreviewingWithDelegate:(id  <UIViewControllerPreviewingDelegate>)delegate sourceViews:(NSArray<UIView *> *)sourceViews previewActionTitles:(NSArray <NSString *>*)titles;

 Example:
    [self lb_registerForPreviewingWithDelegate:self sourceViews:_imageViews previewActionTitles:@[@"保存图片",@"分享",@"识别二维码",@"取消"]];
    
 2 给对应的控制器 遵守协议 <UIViewControllerPreviewingDelegate>  
 
 3 实现代理方法 , 代理方法
@protocol LBTouchVCPreviewingDelegate <UIViewControllerPreviewingDelegate>

@required

// 3Dtouch触发后的事件--> 即接下来应该展示什么
- (void)lb_showPhotoBrowserFormImageView:(UIImageView *_Nullable)imageView;

@optional

// 3Dtouch下面的操作按钮的点击事件
- (void)lb_userDidSelectedPreviewTitle:(NSString *_Nullable)title;

// 3Dtouch下面的操作按钮的样式 不实现该方法,采用默认样式
- (UIPreviewActionStyle)lb_previewActionStyleForActionTitle:(NSString *_Nullable)title index:(NSInteger)index inTitles:(NSArray <NSString *>*_Nullable)titles;

// 当3dTouch预览图片还没有加载出来显示的图片  不实现该方法 采用默认样式
- (UIImage *)lb_3DTouchPlaceholderImageForImageView:(UIImageView *)imageView;

@end
 
 ```
