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

@property (nonatomic , strong)NSArray *urls;

@property (nonatomic , strong)NSArray *imageViews;

@property (nonatomic , strong)NSArray *titles;

@end


@implementation ViewController

- (NSArray *)urls {
    if (!_urls) {
        _urls = @[
                  @"http://pic49.nipic.com/file/20140927/19617624_230415502002_2.jpg",
                  
                  @"https://ss0.bdstatic.com/70cFvHSh_Q1YnxGkpoWK1HF6hhy/it/u=100334575,2106529211&fm=117&gp=0.jpg",
                  
                  @"https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1503555021950&di=17c2df6a4e00eb9cd903ca4b242420e6&imgtype=0&src=http%3A%2F%2Fpic.92to.com%2Fanv%2F201606%2F27%2Feo5n02tvqa5.gif",
                  
                  // 这个gif144张 全部加载在内存中占用210M
                  @"https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1504425455943&di=26c76de065684dcca127e0970254518c&imgtype=0&src=http%3A%2F%2Fimg.zcool.cn%2Fcommunity%2F0143d4578075450000012e7eb2106a.gif",
                  
                  @"https://ss3.bdstatic.com/70cFv8Sh_Q1YnxGkpoWK1HF6hhy/it/u=1929354940,3549861327&fm=117&gp=0.jpg",
                  
                  @"http://ww4.sinaimg.cn/bmiddle/406ef017jw1ec40av2nscj20ip4p0b29.jpg"
                  ];
    }
    return _urls;
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
        NSURL *url = [NSURL URLWithString:self.urls[i]];
        [imageView sd_setImageWithURL:url];
    }
    // 添加3d touch功能 --> LB3DTouchVC 已经把该做的都做了 只管用就好
    [self lb_registerForPreviewingWithDelegate:self sourceViews:_imageViews previewActionTitles:@[@"保存图片",@"分享",@"识别二维码",@"取消"]];
}

- (void)imageViewClick:(UITapGestureRecognizer *)tap {
    [[LBPhotoBrowserManager defaultManager] showImageWithURLArray:_urls fromImageViews:_imageViews selectedIndex:(int)tap.view.tag imageViewSuperView:self.view];
    
    // 添加图片浏览器长按手势的效果
    [[[LBPhotoBrowserManager defaultManager] addLongPressShowTitles:self.titles] addTitleClickCallbackBlock:^(UIImage *image, NSIndexPath *indexPath, NSString *title) {
        LBPhotoBrowserLog(@"%@ %@ %@",image,indexPath,title);
    }].style = LBMaximalImageViewOnDragDismmissStyleOne; // 默认的就是LBMaximalImageViewOnDragDismmissStyleOne
    
    // 给每张图片添加占位图
    [[[LBPhotoBrowserManager defaultManager] addPlaceHoldImageCallBackBlock:^UIImage *(NSIndexPath *indexPath) {
        LBPhotoBrowserLog(@"%@",indexPath);
        return [UIImage imageNamed:@"LBLoading.png"];
    }]addPhotoBrowserWillDismissBlock:^{
        LBPhotoBrowserLog(@" LBPhotoBrowser --> 即将销毁 ");
    }].lowGifMemory = YES; // lowGifMemory 这个在真机上效果明显 模拟器用的是电脑的内存;
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

@end
