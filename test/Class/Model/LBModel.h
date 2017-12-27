//
//  LBModel.h
//  test
//
//  Created by dengweihao on 2017/12/26.
//  Copyright © 2017年 dengweihao. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface LBURLModel : NSObject

@property (nonatomic , copy)NSString *thumbnailURLString;
@property (nonatomic , copy)NSString *largeURLString;

@end

@interface LBModel : NSObject
@property (nonatomic , strong)NSMutableArray <LBURLModel *>*urls;
@property (nonatomic , strong)NSMutableArray *frames;
@property (nonatomic , assign)CGFloat height;

- (void)loadFrames;
@end
