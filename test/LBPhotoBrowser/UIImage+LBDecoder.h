//
//  UIImage+Decoder.h
//  test
//
//  Created by dengweihao on 2017/8/23.
//  Copyright © 2017年 llb. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (LBDecoder)

//存储图片
@property (nonatomic, setter = lb_setImageBuffer:,getter=lb_imageBuffer) NSMutableDictionary *buffer;

//是否需要不停刷新buffer
@property (nonatomic, setter = lb_setNeedUpdateBuffer:,getter=lb_needUpdateBuffer) NSNumber *needUpdateBuffer;

// 当前展示到那一张图片了
@property (nonatomic, setter = lb_setHandleIndex:,getter=lb_handleIndex) NSNumber *handleIndex;

// 最大的缓存图片数
@property (nonatomic, setter = lb_setMaxBufferCount:,getter=lb_maxBufferCount) NSNumber *maxBufferCount;

// 当前这帧图像是否展示
@property (nonatomic, setter = lb_setBufferMiss:,getter=lb_bufferMiss) NSNumber *bufferMiss;

// 增加的buffer数目
@property (nonatomic, setter = lb_setIncrBufferCount:,getter=lb_incrBufferCount)NSNumber *incrBufferCount;

// 该gif 一共多少帧
@property (nonatomic, setter = lb_setTotalFrameCount:,getter=lb_totalFrameCount)NSNumber *totalFrameCount;

+ (UIImage *)sdOverdue_animatedGIFWithData:(NSData *)data;

- (void)lb_animatedGIFData:(NSData *)data;

- (NSTimeInterval)animatedImageDurationAtIndex:(int)index;

- (UIImage *)animatedImageFrameAtIndex:(int)index;

- (void)imageViewShowFinsished;
@end
