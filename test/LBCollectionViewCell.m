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
    _gifLabel.alpha = 0.5;
}

- (void)setUrlString:(NSString *)urlString {
    _urlString = urlString;
    BOOL isRemote = isRemoteAddress(urlString);
    if (isRemote) {
        NSURL *url = [NSURL URLWithString:urlString];
        [_showImageView sd_setImageWithURL:url];
    }else {
        _showImageView.image = [UIImage imageWithContentsOfFile:urlString];
    }
    _gifLabel.hidden = ![self showGifLabelwithUrl:urlString];
}

- (BOOL)showGifLabelwithUrl:(NSString *)urlString{
    if (![urlString hasSuffix:@".gif"]) {
        return NO;
    }
    return YES;
}
@end
