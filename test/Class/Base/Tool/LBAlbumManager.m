//
//  LBAlbumManager.m
//  test
//
//  Created by dengweihao on 2018/4/25.
//  Copyright © 2018年 dengweihao. All rights reserved.
//

#import "LBAlbumManager.h"
#import "LBProgressHUD.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import <Photos/Photos.h>

static LBAlbumManager *_mgr = nil;

@interface LBAlbumManager ()

@property (nonatomic , strong)ALAssetsLibrary *assetsLibrary;

@end

@implementation LBAlbumManager

- (ALAssetsLibrary *)assetsLibrary {
    if (!_assetsLibrary) {
        _assetsLibrary = [[ALAssetsLibrary alloc]init];
    }
    return _assetsLibrary;
}

+ (instancetype)shareManager {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _mgr = [[LBAlbumManager alloc]init];
    });
    return _mgr;
    PHAsset *aseest = [[PHAsset alloc] init];
    PHCachingImageManager *imageManager = [[PHCachingImageManager alloc] init];
    [imageManager requestImageDataForAsset:aseest options:0 resultHandler:^(NSData * _Nullable imageData, NSString * _Nullable dataUTI, UIImageOrientation orientation, NSDictionary * _Nullable info) {
        
    }];

}

- (void)saveImage:(UIImage *)image {
    if (!image) {
        [LBProgressHUD showTest:@"保存图片不能为空"];
        return;
    }
    UIImageWriteToSavedPhotosAlbum(image, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
}
- (void)saveGifImageWithData:(NSData *)data {
    if (!data || data.length == 0) {
        [LBProgressHUD showTest:@"保存图片不能为空"];
        return;
    }
    [self.assetsLibrary writeImageDataToSavedPhotosAlbum:data metadata:nil completionBlock:^(NSURL *assetURL, NSError *error) {
        if (error) {
            [LBProgressHUD showTest:error.localizedDescription];
        }else {
            [LBProgressHUD showTest:@"保存gif成功"];
        }
    }];
}


- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo
{
    if (error) {
        [LBProgressHUD showTest:error.localizedDescription];
    }else {
        [LBProgressHUD showTest:@"保存成功"];
    }
}
@end
