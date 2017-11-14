//
//  LBTest.m
//  test
//
//  Created by dengweihao on 2017/11/14.
//  Copyright © 2017年 dengweihao. All rights reserved.
//

#import "LBTest.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import <SDWebImage/SDWebImageManager.h>
#import <SDWebImage/UIImage+MultiFormat.h>
@interface LBTest ()

@property (weak, nonatomic) IBOutlet UIImageView *testImageView1;

@property (weak, nonatomic) IBOutlet UIImageView *testImageView2;

@property (weak, nonatomic) IBOutlet UIImageView *testImageView3;
@end

@implementation LBTest

- (void)viewDidLoad {
    [super viewDidLoad];
    /**
     sd内调用了 sd_imageWithData 这个方法来处理gif图片 导致了这个问题的产生
     */
    NSString *urlString = @"https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1503555021950&di=17c2df6a4e00eb9cd903ca4b242420e6&imgtype=0&src=http%3A%2F%2Fpic.92to.com%2Fanv%2F201606%2F27%2Feo5n02tvqa5.gif";
    NSURL *url = [NSURL URLWithString:urlString];
    [_testImageView1 sd_setImageWithURL:url placeholderImage:[UIImage imageNamed:@"LBLoadError.jpg"]];
    
    NSData *data = [NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"timg.gif" ofType:nil]];
    UIImage *image = [UIImage sd_imageWithData:data];
    _testImageView2.image = image;
    
    __weak typeof(self) wself = self;
    [SDWebImageManager.sharedManager loadImageWithURL:url options:SDWebImageRetryFailed progress:nil completed:^(UIImage * _Nullable image, NSData * _Nullable data, NSError * _Nullable error, SDImageCacheType cacheType, BOOL finished, NSURL * _Nullable imageURL) {
        if (image.images.count > 0) {
            wself.testImageView3.image = [UIImage imageWithData:data];
        }
    }];

}


@end
