# LBPhotoBrowser

一个使用简单的图片浏览器, 实现类似微信和今日头条的图片浏览效果

简书地址:[http://www.jianshu.com/p/00f4b7b20dc4](http://www.jianshu.com/p/00f4b7b20dc4)(详细说明)

An easy way to make photo browse

# 概览(Overview)

LBPhotoBrowser对gif图片的加载机制:
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
   
   建议使用第二种加载方式 即 `lowGifMemory` = `YES`, 通过`LBPhotoBrowserManager`的`lowGifMemory`属性控制
   
```
LBPhotoBrowser对网络图片的预加载机制:

```
LBPhotoBrowser 将网络图片的加载分为两种:
  
 (1)缩略图和大图使用同一个url 不提共预加载
 
 (2)缩略图和大图使用不同的url 提供预加载  
 
    * 当点击图片,通过LBPhotoBrowser展示大图的过程中,LBPhotoBrowser会自动提前加载当前图片左右两张图片,以方便用户浏览
    
    * 当用户在滑动图片的过程中,LBPhotoBrowser会始终保持优先加载当前展示图片和当前展示图片左右两张的图片,并且停止离当前图片较远图片的加载
    
    * 当用户退出LBPhotoBrowser,停止所有图片的加载
   
   当你使用(1)展示图片的时候,请设置`LBPhotoBrowserManager`的`cancelLoadImageWhenRemove` = `NO`. 
   
   注:
      缩略图: 当前展示给用户的图片
        大图: 点击缩略图后,使用LBPhotoBrowser展示给用户的图片
```

# 使用(Usage)

LBPhotoBrowser 支持本地图片和网络图片 以及gif的播放

效果1:加载本地图片,支持相册中的gif的图片 

![](https://github.com/tianliangyihou/zhuxian/blob/master/effect0.gif?raw=true)

```obj-c
  for (UIImageView *imageView in self.imageViews) {
        LBPhotoLocalItem *item = [[LBPhotoLocalItem alloc]initWithImage:imageView.image frame:imageView.frame];
        [items addObject:item];
    }
    __weak typeof(self)wself = self
   // 这里只要你开心 可以无限addBlock
    [[[[LBPhotoBrowserManager defaultManager] showImageWithLocalItems:items selectedIndex:tap.view.tag fromImageViewSuperView:self.view] addLongPressShowTitles:@[@"保存图片",@"识别二维码",@"取消"]] addTitleClickCallbackBlock:^(UIImage *image, NSIndexPath *indexPath, NSString *title) {
        NSLog(@"%@",title);
    }];
    [[LBPhotoBrowserManager defaultManager] addPhotoBrowserWillDismissBlock:^{
        wself.hideStatusBar = NO;
        [wself setNeedsStatusBarAppearanceUpdate];
    }].lowGifMemory = NO;
 ```
效果2:加载网络图片,实现类似微信的图片浏览效果,缩略图和大图使用不同的url

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

效果3:加载网络图片,实现类似今日头条的图片浏览效果,缩略图和大图使用不同的url

![](https://github.com/tianliangyihou/zhuxian/blob/master/effect2.gif?raw=true)

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

效果4:加载网络图片 缩略图和大图使用同一个url

![](https://github.com/tianliangyihou/zhuxian/blob/master/effect3.gif?raw=true)

```objc
 for (int i = 0 ; i < cellModel.urls.count; i++) {
            LBURLModel *urlModel = cellModel.urls[i];
            UIImageView *imageView = cell.imageViews[i];
            LBPhotoWebItem *item = [[LBPhotoWebItem alloc]initWithURLString:urlModel.largeURLString frame:imageView.frame];
            [items addObject:item];
        }
        [LBPhotoBrowserManager.defaultManager showImageWithWebItems:items selectedIndex:tag fromImageViewSuperView:cell.contentView].lowGifMemory = YES;
      
```



 
 


```objc

```


```objc

```

```objc
关于SDWebImage加载gif图片的问题(sd_setImageWithURL):

当你在真机上运行当前版本的时候,你会发现展示gif的一个问题 => 拖动pop当前界面的时候,imageView上的图片不见了

这个是SDWebImage内部的一个方法导致的,你可以在demo(右上角有个测试按钮)中找到原因和解决办法

```
 
 有时候你也可以这么写:
 ```obj-c
   
  [[[[LBPhotoBrowserManager defaultManager] addLongPressShowTitles:self.titles] addTitleClickCallbackBlock:^(UIImage *image, NSIndexPath *indexPath, NSString *title) {
        LBPhotoBrowserLog(@"%@ %@ %@",image,indexPath,title);
    }]addPlaceHoldImageCallBackBlock:^UIImage *(NSIndexPath *indexPath) {
        return [UIImage imageNamed:@"LBLoading.png"];
    }].lowGifMemory = YES;
 
```

 ```obj-c
 
 ```
