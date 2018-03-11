# LBPhotoBrowser

一个使用简单的图片浏览器, 实现类似微信和今日头条的图片浏览效果 (如果下面的gif图加载不出来或者加载太慢,请移步简书)

简书地址:[https://www.jianshu.com/p/baaab7bd47f3](https://www.jianshu.com/p/baaab7bd47f3)


目前已更新至V2.2.2,新增以下内容:

1.支持通过collectionView展示本地和网络图片(详情可查看demo)

2.修复 lowGifMemory = NO情况下,展示gif图片的一个bug

##### `LBPhotoBrowser`依赖于`SDWebImage`,建议使用`SDWebImage`(v4.0.0)版本
##### 由于最新版的`SDWebImage`(v4.3.2)更新了对了gif图片的处理方式,导致`LBPhotoBrowser`无法播放gif图片(其他都正常).目前正在是适配中...

# 概览(Overview)

`LBPhotoBrowser`对gif图片的加载机制:
```
LBPhotoBrowser对gif的播放提供了两种方式:

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
   
   建议使用第二种加载方式 即 lowGifMemory = YES, 通过 LBPhotoBrowserManager 的 lowGifMemory 属性控制 
   
   当你加载的gif图片较多,并且gif的帧数也比较多,两种方式的差别会特别明显,方式2的优点也越明显.(不要使用模拟器测试)
```
`LBPhotoBrowser`对网络图片的预加载机制:

```
LBPhotoBrowser 将网络图片的加载分为两种:
  
 (1)缩略图和大图使用同一个url 不需要提供预加载
 
 (2)缩略图和大图使用不同的url 提供预加载  
 
    * 当点击图片,通过LBPhotoBrowser展示大图的过程中,LBPhotoBrowser会自动提前加载当前图片左右两张图片,以方便用户浏览
    
    * 当用户在滑动图片的过程中,LBPhotoBrowser会始终保持优先加载当前展示图片和当前展示图片左右两张的图片,并且停止离当前图片较远图片的加载
    
    * 当用户退出LBPhotoBrowser,停止所有图片的加载
   
   当你使用(1)展示图片的时候,请设置`LBPhotoBrowserManager`的`needPreloading` = `NO`. 
   
   注:
      缩略图: 当前展示给用户的图片
        大图: 点击缩略图后,使用LBPhotoBrowser展示给用户的图片
```

# 使用(Usage)

`LBPhotoBrowser` 支持本地图片和网络图片 以及gif的播放,下面四中效果详情可参考demo

### 效果1: 加载本地图片,支持相册中的gif的图片 

![](https://github.com/tianliangyihou/zhuxian/blob/master/effect0.gif?raw=true)

```obj-c
  NSMutableArray *items = [[NSMutableArray alloc]init];
  for (UIImageView *imageView in self.imageViews) {
        LBPhotoLocalItem *item = [[LBPhotoLocalItem alloc]initWithImage:imageView.image frame:imageView.frame];
        [items addObject:item];
    }
  [[LBPhotoBrowserManager defaultManager]showImageWithWebItems:items selectedIndex:tag fromImageViewSuperView:self.view];
 ```
### 效果2: 加载网络图片,实现类似微信的图片浏览效果,缩略图和大图使用不同的url

![](https://github.com/tianliangyihou/zhuxian/blob/master/effect1.gif?raw=true)

```obj-c
 NSMutableArray *items = [[NSMutableArray alloc]init];
 for (int i = 0 ; i < cellModel.urls.count; i++) {
       LBURLModel *urlModel = cellModel.urls[i];
        UIImageView *imageView = cell.imageViews[i];
        LBPhotoWebItem *item = [[LBPhotoWebItem alloc]initWithURLString:urlModel.largeURLString frame:imageView.frame];
        item.placeholdImage = imageView.image;
        [items addObject:item];
     }
   [LBPhotoBrowserManager.defaultManager showImageWithWebItems:items selectedIndex:tag fromImageViewSuperView:cell.contentView].lowGifMemory = YES;
 ```

### 效果3: 加载网络图片,实现类似今日头条的图片浏览效果,缩略图和大图使用不同的url

![](https://github.com/tianliangyihou/zhuxian/blob/master/effect2_new.gif?raw=true)

 ```obj-c
 NSMutableArray *items = [[NSMutableArray alloc]init];
 for (int i = 0 ; i < cellModel.urls.count; i++) {
       LBURLModel *urlModel = cellModel.urls[i];
        UIImageView *imageView = cell.imageViews[i];
        LBPhotoWebItem *item = [[LBPhotoWebItem alloc]initWithURLString:urlModel.largeURLString frame:imageView.frame placeholdImage:imageView.image placeholdSize:imageView.frame.size];
         [items addObject:item];
   }
  [LBPhotoBrowserManager.defaultManager showImageWithWebItems:items selectedIndex:tag fromImageViewSuperView:cell.contentView].lowGifMemory = YES;
 ```

### 效果4: 加载网络图片 缩略图和大图使用同一个url

![](https://github.com/tianliangyihou/zhuxian/blob/master/effect3.gif?raw=true)

```objc
 NSMutableArray *items = [[NSMutableArray alloc]init];
 for (int i = 0 ; i < cellModel.urls.count; i++) {
        LBURLModel *urlModel = cellModel.urls[i];
        UIImageView *imageView = cell.imageViews[i];
         LBPhotoWebItem *item = [[LBPhotoWebItem alloc]initWithURLString:urlModel.largeURLString frame:imageView.frame];
         [items addObject:item];
     }
  [LBPhotoBrowserManager.defaultManager showImageWithWebItems:items selectedIndex:tag fromImageViewSuperView:cell.contentView].lowGifMemory = YES;
  [[LBPhotoBrowserManager defaultManager]addPhotoBrowserWillDismissBlock:^{
    // do something       
   }].needPreloading = NO;
      
```

# 提示(Tip)

##### 关于图片展示过程中,status bar的控制

```objc
对于status bar的处理,相比之前做了较大的优化
采用创建一个新的level 高于status bar 的window 覆盖在之前的window上
效果更佳流畅和自然 (上面展示效果的gif图片 是采用了之前版本的处理方式,如果感觉不流畅,请忽略)
```
##### 保存gif图片的问题
```objc
由于 SDWebImage 返回的image只是这个gif图片的第一帧

1 当lowGifMemory = NO 的情况下,可以直接过
// 默认长按控件的回调
- (instancetype)addTitleClickCallbackBlock:(void(^)(UIImage *image,NSIndexPath *indexPath,NSString *title))titleClickCallBackBlock;
add 这个block 返回的image 进行保存

2 当lowGifMemory = YES的情况下,通过下面这个block返回的data进行保存, 这个也适合方式1
 [[SDImageCache sharedImageCache] queryCacheOperationForKey:currentUrl.absoluteString done:^(UIImage * _Nullable image, NSData * _Nullable data, SDImageCacheType cacheType) {
    
 }];
```
 
##### 使用 `LBPhotoBrowser` 的时候 当你需要添功能的时候 就尝试add Block, `LBPhotoBrowser`可以无限add block,同一个block add多次,后添加的生效

所以你可以这样写,可以更长^_^ ,当然也可以分开写
 ```obj-c
    [[[[LBPhotoBrowserManager.defaultManager addLongPressShowTitles:@[@"保存",@"识别二维码",@"取消"]]addTitleClickCallbackBlock:^(UIImage *image, NSIndexPath *indexPath, NSString *title) {
            // do somehting
        }]addPhotoBrowserWillDismissBlock:^{
            // do somehting
        }]addPhotoBrowserDidDismissBlock:^{
            // do somehting
        }];
```

##### 关于SDWebImage加载gif图片的问题(sd_setImageWithURL):

```objc
当你在真机上运行当前版本的时候,你会发现展示gif的一个问题 => 拖动pop当前界面的时候,imageView上的图片不见了

这个是SDWebImage内部的一个方法导致的.

你可以在demo的style3中(右上角有个测试按钮)中找到原因和解决办法

```

##### `LBPhotoBrowser`的依赖
 ```obj-c
 LBPhotoBrowser 只依赖于SDWebImage,本身实现了gif的解压和播放
 ```
 
 # 相关(Relevant)
 
 #### 这是本人写的一个高仿今日头条的项目,目前还在完善中 部分已有的功能如下:
 采用了RAC + MVVM 的方式  使用了`LBPhotoBrowser`
 #### https://github.com/tianliangyihou/headlineNews
 
![effect_hn.gif](https://github.com/tianliangyihou/zhuxian/blob/master/effect_hn.gif?raw=true)

#### 如果您使用过程中发现什么问题,请及时issue me 或者 简书 下面给我留言 期待和您一起改进`LBPhotoBrowser`
