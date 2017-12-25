//
//  ViewController.m
//  test
//
//  Created by dengweihao on 2017/3/14.
//  Copyright © 2017年 dengweihao. All rights reserved.
//

#import "ViewController.h"
#import "UIView+LBFrame.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "LBPhotoBrowserManager.h"

@interface ViewController ()

@property (weak, nonatomic) IBOutlet UIImageView *imageView1;
@property (weak, nonatomic) IBOutlet UIImageView *imageView2;
@property (weak, nonatomic) IBOutlet UIImageView *imageView3;
@property (weak, nonatomic) IBOutlet UIImageView *imageView4;
@property (weak, nonatomic) IBOutlet UIImageView *imageView5;
@property (weak, nonatomic) IBOutlet UIImageView *imageView6;

@property (nonatomic , strong)NSArray *thumbnailUrlStrings;

@property (nonatomic , strong)NSArray *largeUrlStrings;

@property (nonatomic , strong)NSArray <UIImageView *> *imageViews;


@property (nonatomic , strong)NSArray *titles;

@property (nonatomic , assign)BOOL hide;

@end


@implementation ViewController


- (void)dealloc {
    LBPhotoBrowserLog(@"ViewController 销毁了");
}

- (NSArray *)thumbnailUrlStrings {
    if (!_thumbnailUrlStrings) {
        _thumbnailUrlStrings = @[
                                 // 200 * 200
                                 @"http://p2.pstatp.com/list/s200/4d500005a68341de149a",
                                 // 200 * 200
                                 @"http://p3.pstatp.com/list/s200/4df40000dff9b11bae66",
                                 // 200 * 200
                                 @"http://p7.pstatp.com/list/s200/4df20000df7ef91b0fa8",
                                 // 200 * 200
                                 @"http://p3.pstatp.com/list/s200/4df20000df7d5a6240c4",
                                 // 200 * 200
                                 @"http://p7.pstatp.com/list/s200/4d500005a686aa22dcb3",
                                 // 200 * 200
                                 @"http://ww2.sinaimg.cn/wap720/6204ece1gw1evvzegkumsj20k069f4hm.jpg",
                                 ];
    }
    return _thumbnailUrlStrings;
}

- (NSArray *)largeUrlStrings {
    if (!_largeUrlStrings) {
        _largeUrlStrings = @[
                             //1080 * 912
                             @"http://n1.itc.cn/img8/wb/recom/2016/08/12/147100143815015802.gif",
                             //767 * 1080
                             @"https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1504425455943&di=26c76de065684dcca127e0970254518c&imgtype=0&src=http%3A%2F%2Fimg.zcool.cn%2Fcommunity%2F0143d4578075450000012e7eb2106a.gif",
                             //1322 * 734
                             @"http://p7.pstatp.com/large/w960/4df20000df7ef91b0fa8",
                             //1984 * 1488
                             @"http://p3.pstatp.com/large/w960/4df20000df7d5a6240c4",
                             //1984 * 1488
                             @"http://p7.pstatp.com/large/w960/4d500005a686aa22dcb3",
                             //1984 * 1488
                             @"http://ww2.sinaimg.cn/wap720/6204ece1gw1evvzegkumsj20k069f4hm.jpg",
                             ];
    }
    return _largeUrlStrings;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    
    _imageViews = @[_imageView1,_imageView2,_imageView3,_imageView4,_imageView5,_imageView6];
    _titles = @[ @"发送朋友",@"收藏",@"保存图片",@"识别二维码",@"编辑",@"取消" ];
    for (int i = 0; i < _imageViews.count; i++) {
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(imageViewClick:)];
        UIImageView *imageView = _imageViews[i];
        imageView.backgroundColor = [UIColor grayColor];
        imageView.tag = i;
        [imageView addGestureRecognizer:tap];
        NSURL *url = [NSURL URLWithString:self.thumbnailUrlStrings[i]];
        [imageView sd_setImageWithURL:url];
        [self addGifLabelForImageView:imageView withUrl:self.thumbnailUrlStrings[i]];
    }
}
 
- (void)imageViewClick:(UITapGestureRecognizer *)tap {
    weak_self;
    NSMutableArray *items = @[].mutableCopy;
    for (int i = 0; i < self.largeUrlStrings.count; i++) {
        LBPhotoWebItem *item = [[LBPhotoWebItem alloc]initWithURLString:self.largeUrlStrings[i] frame:self.imageViews[i].frame];
        item.placeholdSize = CGSizeMake(200, 200);
        item.placeholdImage = self.imageViews[i].image;
        [items addObject:item];
    }
    [[[[LBPhotoBrowserManager defaultManager]showImageWithWebItems:items selectedIndex:tap.view.tag fromImageViewSuperView:self.view] addLongPressShowTitles: self.titles] addTitleClickCallbackBlock:^(UIImage *image, NSIndexPath *indexPath, NSString *title) {
        LBPhotoBrowserLog(@"%@",title);
    }].lowGifMemory = YES;
    
    [[LBPhotoBrowserManager defaultManager] addPhotoBrowserWillDismissBlock:^{
        LBPhotoBrowserLog(@"即将销毁");
        _hide = NO;
        [wself setNeedsStatusBarAppearanceUpdate];
    }];
    
    _hide = YES;
    [self setNeedsStatusBarAppearanceUpdate];
}


- (BOOL)prefersStatusBarHidden {
    return _hide;
}

#pragma mark - 给图片添加gif标识

- (void)addGifLabelForImageView:(UIImageView *)imageView withUrl:(NSString *)urlString{
    if (![urlString hasSuffix:@".gif"]) {
        return;
    }
    UILabel *gifLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, imageView.width, 15)];
    gifLabel.font = [UIFont systemFontOfSize:12];
    gifLabel.textColor = [UIColor whiteColor];
    gifLabel.textAlignment = NSTextAlignmentCenter;
    gifLabel.bottom = imageView.height;
    gifLabel.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5];
    gifLabel.text = @"动图";
    [imageView addSubview:gifLabel];
}
@end
