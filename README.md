# LBPhotoBrowser

一个使用简单的图片浏览器, 实现类似微信和今日头条的图片浏览效果,支持本地图片和gif图片的播放

简书地址:[http://www.jianshu.com/p/00f4b7b20dc4](http://www.jianshu.com/p/00f4b7b20dc4)(详细说明)

An easy way to make photo browse

# 问题收集

这是目前的第4个大的版本了,如果你用的时候遇到什么问题(及时保存崩溃日志)或者有什么建议的话,及时issues me,或者简书下面给我留言.

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
   
   建议使用第二中加载方式
```
通过`LBPhotoBrowserManager`的`lowGifMemory`属性控制.
```objc

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

效果图如下:


![](https://github.com/tianliangyihou/zhuxian/blob/master/effect0.gif?raw=true)


![](https://github.com/tianliangyihou/zhuxian/blob/master/effect1.gif?raw=true)

![](https://github.com/tianliangyihou/zhuxian/blob/master/effect2.gif?raw=true)

![](https://github.com/tianliangyihou/zhuxian/blob/master/effect3.gif?raw=true)


```obj-c

 ```

```obj-c
   
 ```
 ```obj-c

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
