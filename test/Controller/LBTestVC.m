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
    NSString *urlString = @"http://p3.pstatp.com/large/w960/53220001268b1a373be9";
    NSURL *url = [NSURL URLWithString:urlString];
    [_testImageView1 sd_setImageWithURL:url placeholderImage:[UIImage imageNamed:@"LBLoadError.jpg"]];
    
    NSData *data = [NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"tmp.gif" ofType:nil]];
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
