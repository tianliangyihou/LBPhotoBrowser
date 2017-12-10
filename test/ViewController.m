//
//  ViewController.m
//  test
//
//  Created by dengweihao on 2017/3/14.
//  Copyright © 2017年 dengweihao. All rights reserved.
//

#import "ViewController.h"
#import "UIView+Frame.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "LBPhotoBrowserManager.h"
#import "LB3DTouchVC.h"
#import <ImageIO/ImageIO.h>

@interface ViewController ()<LBTouchVCPreviewingDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *imageView1;
@property (weak, nonatomic) IBOutlet UIImageView *imageView2;
@property (weak, nonatomic) IBOutlet UIImageView *imageView3;
@property (weak, nonatomic) IBOutlet UIImageView *imageView4;
@property (weak, nonatomic) IBOutlet UIImageView *imageView5;
@property (weak, nonatomic) IBOutlet UIImageView *imageView6;

@property (nonatomic , strong)NSArray *thumbnailUrlStrings;

@property (nonatomic , strong)NSArray *largeUrlStrings;

@property (nonatomic , strong)NSArray *imageViews;

@property (nonatomic , strong)NSArray *titles;

@end


@implementation ViewController

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
                                 @"http://p3.pstatp.com/list/s200/4df30000df219619c35f",
                                 ];
    }
    return _thumbnailUrlStrings;
}

- (NSArray *)largeUrlStrings {
    if (!_largeUrlStrings) {
        _largeUrlStrings = @[
                             //1080 * 912
                             @"http://p2.pstatp.com/large/w960/4d500005a68341de149a",
                             //767 * 1080
                             @"http://p3.pstatp.com/large/w960/4df40000dff9b11bae66",
                             //1322 * 734
                             @"http://p7.pstatp.com/large/w960/4df20000df7ef91b0fa8",
                             //1984 * 1488
                             @"http://p3.pstatp.com/large/w960/4df20000df7d5a6240c4",
                             //1984 * 1488
                             @"http://p7.pstatp.com/large/w960/4d500005a686aa22dcb3",
                             //1984 * 1488
                             @"http://p3.pstatp.com/large/w960/4df30000df219619c35f",
                             ];
    }
    return _largeUrlStrings;
}


- (void)viewDidLoad {
    [super viewDidLoad];    
    _imageViews = @[ _imageView1,_imageView2,_imageView3,_imageView4,_imageView5 ,_imageView6];
    
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
     //添加3d touch功能 --> LB3DTouchVC 已经把该做的都做了 只管用就好
    [self lb_registerForPreviewingWithDelegate:self sourceViews:_imageViews previewActionTitles:@[@"保存图片",@"分享",@"识别二维码",@"取消"]];
}
 
- (void)imageViewClick:(UITapGestureRecognizer *)tap {

    [[LBPhotoBrowserManager defaultManager] showImageWithURLArray:self.largeUrlStrings fromImageViews:_imageViews selectedIndex:(int)tap.view.tag imageViewSuperView:self.view]; // lowGifMemory 这个在真机上效果明显 模拟器用的是电脑的内存
    
    // 添加图片浏览器长按手势的效果
    [[[LBPhotoBrowserManager defaultManager] addLongPressShowTitles:self.titles] addTitleClickCallbackBlock:^(UIImage *image, NSIndexPath *indexPath, NSString *title) {
        LBPhotoBrowserLog(@"%@ %@ %@",image,indexPath,title);
    }].style = LBMaximalImageViewOnDragDismmissStyleOne; // 默认的就是LBMaximalImageViewOnDragDismmissStyleOne
    
    // 给每张图片添加占位图 默认LBLoading.png
    [[[LBPhotoBrowserManager defaultManager] addPlaceHoldImageCallBackBlock:^UIImage *(NSIndexPath *indexPath) {
        LBPhotoBrowserLog(@"%@",indexPath);
        return [UIImage imageNamed:@"LBLoading.png"];
    }]addPhotoBrowserWillDismissBlock:^{
        LBPhotoBrowserLog(@" LBPhotoBrowser --> 即将销毁 ");
    }].lowGifMemory = YES;
}

#pragma mark - LBTouchVCPreviewingDelegate

- (UIPreviewActionStyle)lb_previewActionStyleForActionTitle:(NSString *)title index:(NSInteger)index inTitles:(NSArray<NSString *> *)titles {
    if (index == titles.count - 1) {
        return UIPreviewActionStyleDestructive;
    }
    return UIPreviewActionStyleDefault;
}

- (void)lb_userDidSelectedPreviewTitle:(NSString *)title {
    LBPhotoBrowserLog(@"%@",title);
}

- (void)lb_showPhotoBrowserFormImageView:(UIImageView *)imageView {
    [self imageViewClick:imageView.gestureRecognizers.lastObject];
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
