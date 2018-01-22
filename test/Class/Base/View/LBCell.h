//
//  LBCell.h
//  test
//
//  Created by dengweihao on 2017/12/26.
//  Copyright © 2017年 dengweihao. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LBModel.h"
#define LB_WEAK_SELF __weak typeof(self)wself = self

static  NSString *ID = @"lb.cell";
@interface LBCell : UITableViewCell
@property (nonatomic , strong)NSMutableArray *imageViews;
@property (nonatomic , strong)NSMutableArray *frames;
@property (nonatomic , strong)LBModel *model;
@property (nonatomic , copy)void (^callBack)(LBModel *cellModel, int tag);

@end
