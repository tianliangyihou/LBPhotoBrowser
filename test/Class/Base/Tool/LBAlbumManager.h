//
//  LBAlbumManager.h
//  test
//
//  Created by dengweihao on 2018/4/25.
//  Copyright © 2018年 dengweihao. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LBAlbumManager : NSObject
+ (instancetype)shareManager;
- (void)saveImage:(UIImage *)image;
- (void)saveGifImageWithData:(NSData *)data;
@end
