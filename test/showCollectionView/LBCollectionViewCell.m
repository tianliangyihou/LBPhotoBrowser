//
//  LBCollectionViewCell.m
//  test
//
//  Created by dengweihao on 2017/11/13.
//  Copyright © 2017年 dengweihao. All rights reserved.
//

#import "LBCollectionViewCell.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "LBPhotoBrowserConst.h"
@implementation LBCollectionViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    _showImageView.backgroundColor = [UIColor lightGrayColor];
}

@end
