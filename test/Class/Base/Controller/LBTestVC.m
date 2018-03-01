//
//  LBTestVC.m
//  test
//
//  Created by dengweihao on 2017/12/28.
//  Copyright © 2017年 dengweihao. All rights reserved.
//

#import "LBTestVC.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import <SDWebImage/SDWebImageManager.h>
#import <SDWebImage/UIImage+MultiFormat.h>
#import "UIImage+LBDecoder.h"
@interface LBTestVC ()
@property (weak, nonatomic) IBOutlet UIImageView *testImageView1;

@property (weak, nonatomic) IBOutlet UIImageView *testImageView2;

@property (weak, nonatomic) IBOutlet UIImageView *testImageView3;
@end

@implementation LBTestVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
    /**
     sd内调用了 sd_imageWithData 这个方法来处理gif图片 导致了这个问题的产生
     */
    NSString *urlString = @"http://img.zcool.cn/community/0132f455a6d04432f8758bed5f25a9.gif";
    NSURL *url = [NSURL URLWithString:urlString];
    
    NSBundle *bundle = [NSBundle bundleWithPath:[[NSBundle bundleForClass:[LBTestVC class]] pathForResource:@"LBPhotoBrowser" ofType:@"bundle"]];
    [_testImageView1 sd_setImageWithURL:url placeholderImage:[UIImage imageWithContentsOfFile:[bundle pathForResource:@"LBLoadError.png" ofType:nil]]];

    __weak typeof(self) wself = self;
    [[SDWebImageManager sharedManager] loadImageWithURL:url options:SDWebImageRetryFailed progress:nil completed:^(UIImage * _Nullable image, NSData * _Nullable data, NSError * _Nullable error, SDImageCacheType cacheType, BOOL finished, NSURL * _Nullable imageURL) {
        if (image.images.count > 0) {
            wself.testImageView2.image = image.images.firstObject;
        }
    }];

    [SDWebImageManager.sharedManager loadImageWithURL:url options:SDWebImageRetryFailed progress:nil completed:^(UIImage * _Nullable image, NSData * _Nullable data, NSError * _Nullable error, SDImageCacheType cacheType, BOOL finished, NSURL * _Nullable imageURL) {
        if (image.images.count > 0) {
            wself.testImageView3.image = [UIImage sdOverdue_animatedGIFWithData:data];
        }
    }];
}

@end
