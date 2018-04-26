//
//  LBAlbumManager.h
//  test
//
//  Created by dengweihao on 2018/4/25.
//  Copyright © 2018年 dengweihao. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LBImageAlbumModel:NSObject

@property (nonatomic , assign)BOOL isGif;

@property (nonatomic , strong)UIImage *image;

@property (nonatomic , strong)NSData *gifImageData;

@end

@interface LBAlbumManager : NSObject
+ (instancetype)shareManager;
- (void)saveImage:(UIImage *)image;
- (void)saveGifImageWithData:(NSData *)data;
- (void)selectImagesFromAlbumShow:(void(^)(UIViewController *needToPresentVC))presentBlock imageModels:(void(^)(NSArray <LBImageAlbumModel *> *imageModels))imageModelsBlock maxCount:(int)count;

@end
