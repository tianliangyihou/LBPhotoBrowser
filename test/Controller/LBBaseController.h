//
//  LBBaseController.h
//  test
//
//  Created by dengweihao on 2017/12/27.
//  Copyright © 2017年 dengweihao. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LBCell.h"
#import "LBModel.h"
#import "LBPhotoBrowserManager.h"

@interface LBBaseController : UITableViewController

@property (nonatomic , strong)NSMutableArray *models;

@property (nonatomic , strong)NSArray *lagerURLStrings;

@property (nonatomic , strong)NSArray *thumbnailURLStrings;

@property (nonatomic , assign)BOOL hideStatusBar;

@end
